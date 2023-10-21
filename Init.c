#include <fcntl.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <sys/wait.h>
#include <unistd.h>

#define likely(x) __builtin_expect((x), 1)
#define unlikely(x) __builtin_expect((x), 0)

void runService_SSHServer(void) {
  // Allocate Space for Variables
  char *SSH_PUBLIC_KEY = NULL;

  // Get SSH_PUBLIC_KEY from Environment
  SSH_PUBLIC_KEY = getenv("SSH_PUBLIC_KEY");
  if (unlikely(SSH_PUBLIC_KEY == NULL)) {
    printf("\033[0;31m%s\033[0m%s\n",
           "ERROR: ", "Failed to get \"SSH_PUBLIC_KEY\" from the Environment");
    exit(EXIT_FAILURE);
  }

  // Start openSSH-Server Only When SSH_PUBLIC_KEY is Set
  if (unlikely(strcmp(SSH_PUBLIC_KEY, "YOUR_SSH_PUBLIC_KEY") != 0)) {
    int fileDescriptor = open("/home/coder/.ssh/authorized_keys", O_WRONLY | O_CREAT);
    if (unlikely(fileDescriptor == -1)) {
      printf("\033[0;31m%s\033[0m%s\n",
             "ERROR: ", "Failed Write SSH Public Key to File");
      exit(EXIT_FAILURE);
    }
    int bytesWritten =
        write(fileDescriptor, SSH_PUBLIC_KEY, strlen(SSH_PUBLIC_KEY));
    if (unlikely(bytesWritten != strlen(SSH_PUBLIC_KEY))) {
      printf("\033[0;31m%s\033[0m%s\n",
             "ERROR: ", "Failed Write SSH Public Key to File");
      exit(EXIT_FAILURE);
    }
    close(fileDescriptor);
    printf("\033[0;32m%s\033[0m%s\n", "INFO: ", "Starting openSSH Server");
    fflush(stdout);
    pid_t pidSSH = fork();
    if (unlikely(pidSSH == -1)) {
      printf("\033[0;31m%s\033[0m%s\n", "ERROR: ", "Failed to Fork");
      exit(EXIT_FAILURE);
    } else if (pidSSH == 0) {
      fclose(stdin);
      freopen("/var/log/Shigure/ssh/out", "w", stdout);
      freopen("/var/log/Shigure/ssh/err", "w", stderr);
      seteuid(1000);
      execl("/usr/sbin/service", "service", "ssh", "start", NULL);
      printf("\033[0;31m%s\033[0m%s\n", "ERROR: ", "Failed to Launch openSSH Server");
      exit(EXIT_FAILURE);
    }
    waitpid(pidSSH, NULL, 0);
  } else {
    printf("\033[0;33m%s\033[0m%s\n", "WARNING: ",
           "\"SSH_PUBLIC_KEY\" not Set, not Starting openSSH Server");
  }
}

void runService_CodeServer(void) {
  // Start Code-Server
  printf("\033[0;32m%s\033[0m%s\n", "INFO: ", "Starting Code-Server");
  fflush(stdout);
  pid_t pidCodeServer = fork();
  if (unlikely(pidCodeServer == -1)) {
    printf("\033[0;31m%s\033[0m%s\n", "ERROR: ", "Failed to Fork");
    exit(EXIT_FAILURE);
  } else if (pidCodeServer == 0) {
    fflush(stdout);
    fclose(stdin);
    freopen("/var/log/Shigure/code-server/out", "w", stdout);
    freopen("/var/log/Shigure/code-server/err", "w", stderr);
    setuid(1000);
    execl("/usr/bin/code-server", "code-server", NULL);
    printf("\033[0;31m%s\033[0m%s\n", "ERROR: ", "Failed to Launch Code-Server");
    exit(EXIT_FAILURE);
  }
  waitpid(pidCodeServer, NULL, 0);
}

int main(void) {
  // Refuse to Start as Non-Pid=1 Program
  if (getpid() != 1) {
    printf("\033[0;31m%s\033[0m%s\n", "ERROR: ", "Must be Run as PID 1");
    exit(EXIT_FAILURE);
  }

  // Refuse to Start as Non-Uid=1 Program
  // if (geteuid() != 0) {
  //   printf("\033[0;31m%s\033[0m%s\n", "ERROR: ", "Must be Run as UID 1");
  //   exit(EXIT_FAILURE);
  // }

  runService_SSHServer();

  runService_CodeServer();

  // Collect Zombine Process
  while (1) {
    waitpid(-1, NULL, 0);
  }

  return EXIT_SUCCESS;
}
