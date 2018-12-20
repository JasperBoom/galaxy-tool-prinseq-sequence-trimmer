#!/bin/bash
# Copyright @2007-2019 Free Software Foundation

# Author: Jasper Boom

# Prequisites:
# - sudo cpan JSON

# Galaxy prequisites:
# - sudo ln -s /path/to/folder/Prinseq/prinseq-lite.pl
#              /usr/local/bin/prinseq-lite.pl 
# - sudo ln -s /path/to/folder/Prinseq/prinseq-graphs.pl 
#              /usr/local/bin/prinseq-graphs.pl 
# - sudo ln -s /path/to/folder/Prinseq/prinseq-graphs-noPCA.pl 
#              /usr/local/bin/prinseq-graphs-noPCA.pl 

# The runPrinseq function.
# This function calls the PRINSEQ tool and processes the fastQ file(s).
runPrinseq() {
    prinseq-lite.pl -fastq ${flInput} ${strProcess} \
                    -out_good ${flOutput} > /dev/null 2>&1
}

# The preparePrinseq function.
# This function creates a command string based on user input. The command string
# is formatted for PRINSEQ. When a trimming option has been set to a number
# higher than 0, the option is included in the command string. Every option
# has a check build in for when the command string has not been initialised yet.
preparePrinseq() {
    strProcess=""
    if [ "${disBelowMean}" -gt 0 ]
    then
        if [ -z "${strProcess}" ]
        then
            strProcess="-min_qual_mean ${disBelowMean}"
        else
            strProces=${strProcess}" -min_qual_mean ${disBelowMean}"
        fi
    fi
    if [ "${disAboveMean}" -gt 0 ]
    then
        if [ -z "${strProcess}" ]
        then
            strProcess="-max_qual_mean ${disAboveMean}"
        else
            strProcess=${strProcess}" -max_qual_mean ${disAboveMean}"
        fi
    fi
    if [ "${disBelowGC}" -gt 0 ]
    then
        if [ -z "${strProcess}" ]
        then
            strProcess="-min_gc ${disBelowGC}"
        else
            strProcess=${strProcess}" -min_gc ${disBelowGC}"
        fi
    fi
    if [ "${disAboveGC}" -gt 0 ]
    then
        if [ -z "${strProcess}" ]
        then
            strProcess="-max_gc ${disAboveGC}"
        else
            strProcess=${strProcess}" -max_gc ${disAboveGC}"
        fi
    fi
    if [ "${disBelow}" -gt 0 ]
    then
        if [ -z "${strProcess}" ]
        then
            strProcess="-min_length ${disBelow}"
        else
            strProcess=${strProcess}" -min_length ${disBelow}"
        fi
    fi
    if [ "${disAbove}" -gt 0 ]
    then
        if [ -z "${strProcess}" ]
        then
            strProcess="-max_length ${disAbove}"
        else
            strProcess=${strProcess}" -max_length ${disAbove}"
        fi
    fi
    if [ "${disForward}" -gt 0 ]
    then
        if [ -z "${strProcess}" ]
        then
            strProcess="-trim_left ${disForward}"
        else
            strProcess=${strProcess}" -trim_left ${disForward}"
        fi
    fi
    if [ "${disReverse}" -gt 0 ]
    then
        if [ -z "${strProcess}" ]
        then
            strProcess="-trim_right ${disReverse}"
        else
            strProcess=${strProcess}" -trim_right ${disReverse}"
        fi
    fi
    if [ "${disLength}" -gt 0 ]
    then
        if [ -z "${strProcess}" ]
        then
            strProcess="-trim_to_len ${disLength}"
        else
            strProcess=${strProcess}" -trim_to_len ${disLength}"
        fi
    fi
}

# The getZipOutput function.
# This function loops through the files extracted from the input zip file.
# The unique name of every file is isolated and the input and output files for
# PRINSEQ are defined. When PRINSEQ is done processing, the processed file
# is added to a zip file.
getZipOutput() {
    for strFile in ${strDirectory}_temp/fileStorage/*.fastq;
    do
        strUniqueFileName=$(printf "%s\n" "${strFile##*/}")
        strUniqueFileName=${strUniqueFileName::-6}
        flInput=${strFile}
        flOutput=${strDirectory}_temp/${strUniqueFileName}
        runPrinseq
        if [ -e flZip.zip ]
        then
            zip -jqru flZip.zip ${strDirectory}_temp/${strUniqueFileName}.fastq
        else
            zip -jqr ${strDirectory}_temp/flZip.zip \
                     ${strDirectory}_temp/${strUniqueFileName}.fastq
        fi
    done
}

# The getZipFile function.
# This function copies the input file to the temporary storage directory. The
# input file is searched for, based on its .dat extension. This search will
# output the name of the input file which is used to unzip it into the
# temporary storage directory. After unzipping, the getZipOutput function is
# called.
getZipFile() {
    mkdir -p "${strDirectory}_temp/fileStorage"
    cp ${fisInput} ${strDirectory}_temp
    strZipName=$(find ${strDirectory}_temp -name "*.dat" -printf "%f\n")
    unzip -q ${strDirectory}_temp/${strZipName} -d ${strDirectory}_temp/fileStorage
    getZipOutput
}

# The getFormatFlow function.
# This function creates a temporary storage directory in the output directory.
# It then initiates the correct function chain depending on the file format.
# When processing a single file, the input file is directed to the runPrinseq
# function. When processing a zip file, the file is first unpacked in the
# getZipFile function. When all processes have been completed, the temporary
# working directory is deleted.
getFormatFlow() {
    strDirectory=${fosOutput::-4}
    mkdir -p "${strDirectory}_temp"
    if [ "${disFormat}" = "single" ]
    then
        flInput=${fisInput}
        flOutput=${fosOutput}
        preparePrinseq
        runPrinseq
        cat ${fosOutput}.fastq > ${fosOutput}
        rm ${fosOutput}.fastq
        rm -rf ${strDirectory}_temp
    elif [ "${disFormat}" = "zip" ]
    then
        preparePrinseq
        getZipFile
        cat ${strDirectory}_temp/flZip.zip > ${fosOutput}
        rm -rf ${strDirectory}_temp
    fi
}

# The main function.
main() {
    getFormatFlow
}

# The getopts function.
while getopts ":i:o:f:w:r:l:b:a:g:c:q:u:vh" opt; do
    case ${opt} in
        i)
            fisInput=${OPTARG}
            ;;
        o)
            fosOutput=${OPTARG}
            ;;
        f)
            disFormat=${OPTARG}
            ;;
        w)
            disForward=${OPTARG}
            ;;
        r)  
            disReverse=${OPTARG}
            ;;
        l)
            disLength=${OPTARG}
            ;;
        b)
            disBelow=${OPTARG}
            ;;
        a)  
            disAbove=${OPTARG}
            ;;
        g)
            disBelowGC=${OPTARG}
            ;;
        c)
            disAboveGC=${OPTARG}
            ;;
        q)
            disBelowMean=${OPTARG}
            ;;
        u)
            disAboveMean=${OPTARG}
            ;;
        v)
            echo ""
            echo "runPrinseqTrimmer.sh [0.1.0]"
            echo ""

            exit
            ;;
        h)
            echo ""
            echo "Usage: runPrinseqTrimmer.sh [-h] [-v] [-i INPUT] [-o OUTPUT]"
            echo "                            [-f FORMAT] [-w FORWARD]"
            echo "                            [-r REVERSE] [-l LENGTH]"
            echo "                            [-b BELOW] [-a ABOVE] [-g BELOW]"
            echo "                            [-c ABOVE] [-q BELOW] [-u ABOVE]"
            echo ""
            echo "Optional arguments:"
            echo " -h                    Show this help page and exit"
            echo " -v                    Show the software's version number"
            echo "                       and exit"
            echo " -i                    The location of the input file(s)"
            echo " -o                    The location of the output file(s)"
            echo " -f                    The format of the input" 
            echo "                       file(s) [single/zip]"
            echo " -w                    Trim reads at the 5'-end"
            echo " -r                    Trim reads at the 3'-end"
            echo " -l                    Trim reads from 3'-end to certain"
            echo "                       length"
            echo " -b                    Discard reads below certain length"
            echo " -a                    Discard reads above certain length"
            echo " -g                    Discard reads below certain GC content"
            echo " -c                    Discard reads above certain GC content"
            echo " -q                    Discard reads below certain mean"
            echo "                       quality score"
            echo " -u                    Discard reads above certain mean"
            echo "                       quality score"
            echo ""
            echo "The PRINSEQ tool will trim and discard reads and read"
            echo "sections based on user input and quality thresholds."
            echo ""
            echo "Files in fastQ format should always have a .fastq extension."
            echo ""
            echo "Current PRINSEQ version:"
            prinseq-lite.pl -version
            echo ""
            echo "Source(s):"
            echo " - Schmieder R, Edwards R, Quality control and preprocessing" 
            echo "   of metagenomic datasets."
            echo "   Bioinformatics. 2011; 27(6): 863-864."
            echo "   doi: 10.1093/bioinformatics/btr026"
            echo "   http://prinseq.sourceforge.net/"
            echo ""

            exit
            ;;
        \?)
            echo ""
            echo "You've entered an invalid option: -${OPTARG}."
            echo "Please use the -h option for correct formatting information."
            echo ""

            exit
            ;;
        :)
            echo ""
            echo "You've entered an invalid option: -${OPTARG}."
            echo "Please use the -h option for correct formatting information."
            echo ""

            exit
            ;;
    esac
done

main

# Additional information:
# =======================
#
# Files in fastQ format should always have a .fastq extension.
