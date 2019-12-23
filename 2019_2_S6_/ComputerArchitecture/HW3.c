#include <stdio.h> /* printf, sprintf */
#include <stdlib.h> /* exit */
#include <unistd.h> /* read, write, close */
#include <string.h> /* memcpy, memset */
#include <sys/socket.h> /* socket, connect */
#include <netinet/in.h> /* struct sockaddr_in, struct sockaddr */
#include <netdb.h> /* struct hostent, gethostbyname */

#define BUFSIZE 1024

void error_handling(const char *message);

int main(int argc,char *argv[])
{
  struct sockaddr_in serv_addr;
  struct sockaddr_in clnt_addr;
  int serv_sock, clnt_sock;

  int clnt_addr_size;
  char message[BUFSIZE];
  //char response[BUFSIZE];
  char h[BUFSIZE] = "HTTP/1.1 200 OK\r\nContent-Type: text/html\r\ncharset=UTF-8\r\n\r\n";

  //size_t read_len;
  char *header = h;
  int check;

  if (argc != 2) {
    printf("Usage : %s <port>\n", argv[0]);
    exit(0);
  }
a
  /* create the socket */
  serv_sock = socket(AF_INET, SOCK_STREAM, 0);
  if (serv_sock == -1) error_handling("socket() error");

  memset(&serv_addr,0,sizeof(serv_addr));

  serv_addr.sin_family = AF_INET;
  serv_addr.sin_addr.s_addr = htonl(INADDR_ANY);
  serv_addr.sin_port = htons(atoi(argv[1]));

  if (bind(serv_sock, (struct sockaddr *)&serv_addr, sizeof(serv_addr)) == -1)
    error_handling("bind() error");

  if(listen(serv_sock, 5) == -1) error_handling("listen() error");

  while(1) {
    clnt_addr_size = sizeof(clnt_addr);
    clnt_sock = accept(serv_sock, (struct sockaddr *)&clnt_addr, &clnt_addr_size);

    if(clnt_sock == -1) error_handling("accept() error");

    FILE *fp;


    if (strcmp(argv[2], "/") == 0 || strcmp(argv[2], "/index.html") == 0) fp = fopen("index.html","r");

    if (strcmp(argv[2], "/query.html") == 0) fp = fopen("query.html","r");


    while(fread(message, sizeof(char), BUFSIZE, fp) !=0) {
             //printf("%s\n", header);
            //printf("%s\n", message); //Line for Testing , Ignore
    }


    strcat(header, message);
    //printf("+++ %s\n", header);

    /*
    while((str_len=recv(clnt_sock, header, BUFSIZE, 0)) != 0) {
      write(clnt_sock, header, strlen(header));
      printf("--- %s\n", header);
      write(1, header, str_len);
    }
    */
    send(clnt_sock, header, strlen(header), 0);

    printf("Success!\n");

    fclose(fp);
    close(clnt_sock);
    close(serv_sock);
  }
   return 0;
}

void error_handling(const char *message)
{
    perror(message);
    exit(1);
}
