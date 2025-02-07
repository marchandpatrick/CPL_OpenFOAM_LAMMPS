# start from CPL library and openfoam latest image and add in LAMMPS
FROM cpllibrary/cpl-openfoam
MAINTAINER Edward Smith <edward.smith05@imperial.ac.uk>

#Number of processes to use in build
ENV NPROCS=1

#Get LAMMPS
RUN git clone https://github.com/marchandpatrick/lammps.git /lammps &&  \
    git clone https://github.com/marchandpatrick/CPL_APP_LAMMPS-DEV.git /CPL_APP_LAMMPS-DEV

# library for lammps USER-VTK
RUN apt-get update &&  apt-get install -y apt-utils &&  apt-get install -y libvtk6-dev

RUN ls /usr/include

RUN cd /lammps/src && \
    make yes-USER-VTK && \
    make USER-VTK 
# &&    make mpi


#Build LAMMPS with USER-CPL package from APP 
WORKDIR /CPL_APP_LAMMPS-DEV
RUN echo "/lammps" > /CPL_APP_LAMMPS-DEV/CODE_INST_DIR && \
    echo granular >> config/lammps_packages.in && \
    cd config && \
    sh ./enable-packages.sh make && \
    cd ../ && \
    make patch-lammps

RUN make -j $NPROCS

ENV PATH="/CPL_APP_LAMMPS-DEV/bin:${PATH}"
