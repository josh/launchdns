#include "config.h"

#include <arpa/inet.h>
#include <errno.h>
#include <getopt.h>
#include <signal.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <unistd.h>

#ifdef HAVE_LAUNCH_H
#include <launch.h>
#endif

#define VERSION 1.0.3

#define PORT 0x39d8
#define TTL 600
#define RECV_SIZE 512
#define HEADER_SIZE 12

#define INADDR_LOOPBACK_INIT { 0x0100007f }

#define STR_HELPER(x) #x
#define STR(x) STR_HELPER(x)

static const struct option longoptions[] = {
	{"socket", 1, NULL, 's'},
	{"timeout", 1, NULL, 't'},
	{"port", 1, NULL, 'p'},
	{"a", 1, NULL, '4'},
	{"aaaa", 1, NULL, '6'},
	{"version", 0, NULL, 'v'},
	{ NULL, 0, NULL, 0 }
};

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
		.sin_port = PORT,
		.sin_addr = INADDR_LOOPBACK_INIT
	};

	// Default A record to 127.0.0.1
	struct in_addr a = INADDR_LOOPBACK_INIT;

	// Default AAAA record to ::1
	struct in6_addr aaaa = IN6ADDR_LOOPBACK_INIT;

	int timeout = 0;

	int opt;

	while ((opt = getopt_long(argc, argv, "s:t:p:4:6:v", longoptions, NULL)) != EOF) {
		switch (opt) {
			case 's':
				name = optarg;
				break;
			case 't':
				timeout = atoi(optarg);
				break;
			case 'p':
				addr.sin_port = htons(atoi(optarg));
				break;
			case '4':
				inet_pton(AF_INET, optarg, &a);
				break;
			case '6':
				inet_pton(AF_INET6, optarg, &aaaa);
				break;
			case 'v':
				printf("launchdns " STR(VERSION));
				#ifndef HAVE_LAUNCH_ACTIVATE_SOCKET
								printf(" (without socket activation)");
				#endif
				printf("\n");
				exit(0);
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
			fprintf(stderr, "Could not open socket on %i: %s\n", ntohs(addr.sin_port), strerror(errno));
			return 1;
		}
	} else {
#ifdef HAVE_LAUNCH_ACTIVATE_SOCKET
		int *c_fds;
		size_t c_cnt;

		err = launch_activate_socket(name, &c_fds, &c_cnt);
		if (err == 0) {
			sd = c_fds[0];
		} else {
			fprintf(stderr, "Could not activate launchd socket `%s'\n", name);
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

	char msg[RECV_SIZE + 30];
	struct sockaddr caddr;
	socklen_t len = sizeof(caddr);
	int flags = 0;

	while (quit == 0) {
		int n = recvfrom(sd, msg, RECV_SIZE, flags, &caddr, &len);

		if (n < HEADER_SIZE) {
			continue;
		}

		int qdcount = msg[5] | msg[4] << 8;

		if (qdcount < 1) {
			continue;
		}

		int i = HEADER_SIZE;

		while (i < n && msg[i] != 0) {
			i += msg[i] + 1;
		}

		int ans = i + 5;

		if (i == HEADER_SIZE || n < ans) {
			continue;
		}

		int qtype = msg[i+2] | msg[i+1] << 8;
		int qclass = msg[i+4] | msg[i+3] << 8;

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
			msg[ans++] = 0xc0;
			msg[ans++] = 0x0c;

			// RR Type
			msg[ans++] = qtype >> 8;
			msg[ans++] = qtype;

			// RR Class
			msg[ans++] = qclass >> 8;
			msg[ans++] = qclass;

			// TTL
			uint32_t ttl = TTL;
			msg[ans++] = ttl >> 24;
			msg[ans++] = ttl >> 16;
			msg[ans++] = ttl >> 8;
			msg[ans++] = ttl;

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
			msg[ans++] = rsize >> 8;
			msg[ans++] = rsize;

			// RDATA
			memcpy(&msg[ans], rdata, rsize);
			ans += rsize;
		} else {
			// NXDomain
			msg[2] = 0x81;
			msg[3] = 0x03;
		}

		sendto(sd, msg, ans, flags, &caddr, len);
	}

	close(sd);
	return 0;
}
