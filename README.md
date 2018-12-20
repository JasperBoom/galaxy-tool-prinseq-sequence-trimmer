# galaxy-tool-prinseq-sequence-trimmer
Use PRINSEQ to trim and discard reads and read sections.  
The PRINSEQ tool will trim and discard reads and read sections based on user input and quality thresholds.

Files in fastQ format should always have a .fastq extension.

## Getting started

### Prerequisites
Download and install the following software according to the following steps.
* [PRINSEQ](https://sourceforge.net/projects/prinseq/files/)

The PRINSEQ folder should be moved to the following file and renamed to "Prinseq".
```
sudo mkdir -m 755 /home/Tools
/home/Tools <-- Move PRINSEQ to this directory
sudo chmod -R 755 /home/Tools/Prinseq
```
The following three files in the PRINSEQ folder should be made avaible from any location.
```
sudo ln -s /home/Tools/Prinseq/prinseq-lite.pl /usr/local/bin/prinseq-lite.pl
sudo ln -s /home/Tools/Prinseq/prinseq-graphs.pl /usr/local/bin/prinseq-graphs.pl
sudo ln -s /home/Tools/Prinseq/prinseq-graphs-noPCA.pl /usr/local/bin/prinseq-graphs-noPCA.pl
```
```
sudo cpan JSON
```

### Installing
Download and install the tool according to the following steps.
```
cd /home/Tools
sudo git clone https://github.com/JasperBoom/galaxy-tool-prinseq-sequence-trimmer
sudo chmod -R 755 galaxy-tool-prinseq-sequence-trimmer
```
```
sudo mkdir -m 755 /home/galaxy/tools/directoryname
sudo cp /home/Tools/galaxy-tool-prinseq-sequence-trimmer/runPrinseqTrimmer.sh /home/galaxy/tools/directoryname/runPrinseqTrimmer.sh
sudo cp /home/Tools/galaxy-tool-prinseq-sequence-trimmer/runPrinseqTrimmer.xml /home/galaxy/tools/directoryname/runPrinseqTrimmer.xml
```
Edit the following file in order to make galaxy display the tool.
```
/home/galaxy/config/tool_conf.xml
```
```
<tool file="airdentification/runPrinseqTrimmer.xml"/>
```

## Source(s)
* __Schmieder R, Edwards R__, Quality control and preprocessing of metagenomic datasets.  
  Bioinformatics. 2011; 27(6): 863-864. __doi: 10.1093/bioinformatics/btr026__  
  [PRINSEQ](http://prinseq.sourceforge.net/)
* __Giardine B, Riemer C, Hardison RC, Burhans R, Elnitski L, Shah P__,  
  Galaxy: A platform for interactive large-scale genome analysis.  
  Genome Research. 2005; 15(10) 1451-1455 __doi: 10.1101/gr.4086505__  
  [GALAXY](https://www.galaxyproject.org/)
