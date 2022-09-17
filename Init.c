#include <fcntl.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <unistd.h>

int main(void) {
  // Allocate Space for Variables
  char *SSH_PUBLIC_KEY = NULL;

  // Get SSH_PUBLIC_KEY from Environment
  SSH_PUBLIC_KEY = getenv("SSH_PUBLIC_KEY");
  if (SSH_PUBLIC_KEY == NULL) {
    printf("\033[0;31m%s\033[0m%s\n",
           "ERROR: ", "Failed to get \"SSH_PUBLIC_KEY\" from the Environment");
    exit(EXIT_FAILURE);
  }

  // Start openSSH-Server Only When SSH_PUBLIC_KEY is Set
  if (strcmp(SSH_PUBLIC_KEY, "YOUR_SSH_PUBLIC_KEY") != 0) {
    int fileDescriptor = open("/root/.ssh/authorized_keys", O_WRONLY | O_CREAT);
    if (fileDescriptor == -1) {
      printf("\033[0;31m%s\033[0m%s\n",
             "ERROR: ", "Failed Write SSH Public Key to File");
      exit(EXIT_FAILURE);
    }
    int bytesWritten =
        write(fileDescriptor, SSH_PUBLIC_KEY, strlen(SSH_PUBLIC_KEY));
    if (bytesWritten != strlen(SSH_PUBLIC_KEY)) {
      printf("\033[0;31m%s\033[0m%s\n",
             "ERROR: ", "Failed Write SSH Public Key to File");
      exit(EXIT_FAILURE);
    }
    close(fileDescriptor);
    printf("\033[0;32m%s\033[0m%s\n", "INFO: ", "Starting openSSH Server");
    system("service ssh start 1>/dev/null");
  } else {
    printf("\033[0;33m%s\033[0m%s\n", "WARNING: ",
           "\"SSH_PUBLIC_KEY\" not Set, not Starting openSSH Server");
  }

  // Start Code-Server
  printf("\033[0;32m%s\033[0m%s\n", "INFO: ", "Starting Code-Server");
  system("code-server");

  return EXIT_SUCCESS;
}
