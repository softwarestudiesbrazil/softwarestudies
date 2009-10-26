#include "mpi.h"
#include "unistd.h"
#include "stdio.h"
 
#define WANTTASK 10
#define IDTASK 11
#define TASKCMD 12
#define NOTASKS -1

int main (int argc, char *argv[])
{
#define MAXCMD 1024
  FILE *cmdfile;
  char *cmdline;
  int sizcmdline, lencmdline;
  char *cmdfilename;
  int this_process, num_processes, num_slaves, this_slave;
  MPI_Status status;
  int taskid, dummy, error_code, i;

/* 
**  First, get MPI initialized 
*/
 
  if ((error_code = MPI_Init(&argc, &argv)) != MPI_SUCCESS)
  {
    printf("MPI_Init error\n");
    exit(1);
  }

  if ((error_code = MPI_Comm_size(MPI_COMM_WORLD, &num_processes)) != MPI_SUCCESS)
  {
    printf("MPI_Comm_size error\n");
    MPI_Abort(MPI_COMM_WORLD, 1);
  }
  if ((error_code = MPI_Comm_rank(MPI_COMM_WORLD, &this_process)) != MPI_SUCCESS)
  {
    printf("MPI_Comm_rank error\n");
    MPI_Abort(MPI_COMM_WORLD, 1);
  }
  printf("rank= %d size= %d \n", this_process, num_processes);

  sizcmdline = MAXCMD+1;
  cmdline = (void *)malloc((size_t)sizcmdline);
  /*cmdline = (char *)malloc((size_t)sizcmdline);*/

/* 
**  Master reads command file and hands out tasks to slaves.
*/

  if (this_process == 0)			/* Master process */
  {
    if (argc != 2)
    {
      printf("No command file specified\n");
      MPI_Abort(MPI_COMM_WORLD, 1);
    }
    cmdfilename = (char *)malloc((size_t)strlen(argv[1]) + 1);
    strcpy(cmdfilename, argv[1]);
    if ((cmdfile = fopen(cmdfilename, "r")) == NULL)
    {
      printf("Unable to open command file: %s\n", cmdfilename);
      MPI_Abort(MPI_COMM_WORLD, 1);
    }
    taskid = 0;
    num_slaves = num_processes - 1;
    while (num_slaves > 0)
    {
      MPI_Recv(&dummy, 1, MPI_INT, MPI_ANY_SOURCE, WANTTASK, MPI_COMM_WORLD, &status);
      this_slave = status.MPI_SOURCE;
      lencmdline = getline(&cmdline, &sizcmdline, cmdfile);
      if (lencmdline != -1) 
      {
	taskid += 1;
        MPI_Send(&taskid, 1, MPI_INT, this_slave, IDTASK, MPI_COMM_WORLD);
        MPI_Send(cmdline, lencmdline, MPI_CHAR, this_slave, TASKCMD, MPI_COMM_WORLD);
      }
      else
      {
	taskid = NOTASKS;
        MPI_Send(&taskid, 1, MPI_INT, this_slave, IDTASK, MPI_COMM_WORLD);
	num_slaves -= 1;
      }
    }
  }
  else						/* Slave process */
  {
/*
**  Ask master for work
**  If work, do work, tell master when done
**  If no work, go to MPI_Finalize (barrier first?)
*/
    while (1)
    {
      taskid = NOTASKS;
      MPI_Send(&taskid, 1, MPI_INT, 0, WANTTASK, MPI_COMM_WORLD);
      MPI_Recv(&taskid, 1, MPI_INT, 0, IDTASK, MPI_COMM_WORLD, &status);
      if (taskid != NOTASKS)
      {
        MPI_Recv(cmdline, MAXCMD, MPI_CHAR, 0, TASKCMD, MPI_COMM_WORLD, &status);
        system(cmdline);
      }
      else
      {
	break;
      }
    }
  }

  MPI_Barrier(MPI_COMM_WORLD);
  MPI_Finalize();
 
  return(0);
}
