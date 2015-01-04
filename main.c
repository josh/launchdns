#include <arpa/inet.h>
#include <getopt.h>
#include <signal.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>

#ifdef HAVE_LAUNCH_H
#include <launch.h>
#endif

#define PORT 55353
#define TTL 600
#define MSG_SIZE 512

volatile sig_atomic_t quit = 0;

void quit_handler()
{
	quit = 1;
}

int main(int argc, char **argv)
{
	char *name = NULL;

	// Default socket on 127.0.0.1:55353
	struct sockaddr_in addr = {
		.sin_family = AF_INET,
		.sin_port = htons(PORT),
		.sin_addr.s_addr = htonl(INADDR_LOOPBACK)
	};

	// Default A record to 127.0.0.1
	struct in_addr a = {
		.s_addr = htonl(INADDR_LOOPBACK)
	};

	// Default AAAA record to ::1
	struct in6_addr aaaa = IN6ADDR_LOOPBACK_INIT;

	int timeout = 0;

	struct option longoptions[] = {
		{"socket", 1, NULL, 's'},
		{"timeout", 1, NULL, 't'},
		{"port", 1, NULL, 'p'},
		{"a", 1, NULL, '4'},
		{"aaaa", 1, NULL, '6'}
	};

	int opt;

	while ((opt = getopt_long(argc, argv, "s:p:4:6:t:", longoptions, NULL)) != EOF) {
		switch (opt) {
			case 's':
				name = optarg;
				break;
			case 'p':
				addr.sin_port = htons(atoi(optarg));
				break;
			case 't':
				timeout = atoi(optarg);
				break;
				case '4':
				inet_pton(AF_INET, optarg, &a);
				break;
			case '6':
				inet_pton(AF_INET6, optarg, &aaaa);
				break;
			default:
				exit(1);
				break;
		}
	}

	int sd, err;
	if (name == NULL) {
		sd = socket(AF_INET, SOCK_DGRAM, 0);
		err = bind(sd, (struct sockaddr *)&addr, sizeof(addr));
		if (err < 0) {
			fprintf(stderr, "couldn't open socket\n");
			return 1;
		}
	} else {
#ifdef HAVE_LAUNCH_H
		int *c_fds;
		size_t c_cnt;

		err = launch_activate_socket(name, &c_fds, &c_cnt);
		if (err == 0) {
			sd = c_fds[0];
		} else {
			fprintf(stderr, "couldn't activate socket\n");
			return 1;
		}
#else
		fprintf(stderr, "launchd not supported\n");
		return 1;
#endif
	}

	struct sigaction sa;
	sa.sa_handler = &quit_handler;

	if (timeout != 0) {
		sigaction(SIGALRM, &sa, NULL);
		alarm(timeout);
	}
	sigaction(SIGTERM, &sa, NULL);

	char msg[MSG_SIZE];
	struct sockaddr caddr;
	socklen_t len = sizeof(caddr);
	int flags = 0;

	while (quit == 0) {
		int n = recvfrom(sd, msg, MSG_SIZE, flags, &caddr, &len);

		if (n < 1) {
			continue;
		}

		int qtype = msg[n-3] | msg[n-4] << 8;
		int qclass = msg[n-1] | msg[n-2] << 8;

		if (qclass == 0x01 && (qtype == 0x01 || qtype == 0x1c)) {
			// Opcode
			msg[2] = 0x81;
			msg[3] = 0x80;

			// ANCOUNT
			msg[6] = 0x00;
			msg[7] = 0x01;

			// NSCOUNT
			msg[8] = 0x00;
			msg[9] = 0x00;

			// ARCOUNT
			msg[10] = 0x00;
			msg[11] = 0x00;

			// RR Name
			msg[n++] = 0xc0;
			msg[n++] = 0x0c;

			// RR Type
			msg[n++] = qtype >> 8;
			msg[n++] = qtype;

			// RR Class
			msg[n++] = qclass >> 8;
			msg[n++] = qclass;

			// TTL
			uint32_t ttl = TTL;
			msg[n++] = ttl >> 24;
			msg[n++] = ttl >> 16;
			msg[n++] = ttl >> 8;
			msg[n++] = ttl;

			void *rdata;
			uint16_t rsize;
			if (qtype == 0x01) {
				rdata = &a.s_addr;
				rsize = sizeof(a.s_addr);
			} else {
				rdata = &aaaa.s6_addr;
				rsize = sizeof(aaaa.s6_addr);
			}

			// RD Length
			msg[n++] = rsize >> 8;
			msg[n++] = rsize;

			// RDATA
			memcpy(&msg[n], rdata, rsize);
			n += rsize;
		} else {
			// NXDomain
			msg[2] = 0x81;
			msg[3] = 0x03;
		}

		sendto(sd, msg, n, flags, &caddr, len);
	}

	return 0;
}
