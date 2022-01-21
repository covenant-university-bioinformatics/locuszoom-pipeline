#!/usr/bin/env bash
#wget https://statgen.sph.umich.edu/locuszoom/download/locuszoom_1.4.tgz


#Input format
    # 1. METAL formatted file. The file must have 2 columns: markers (SNPs), and p-values. {--metal}. Columns names: "MarkerName" and "P-value"
    # 2. EPACTS formatted file: Tab delimited file, The chrom, start, end, marker ID, and p-value columns must all be present.{--epacts}
    
##If p-values are already log transformed, uers use --no-transform option so that  LocusZoom will not transform p-values.  

# Region to plot    
    # 1- A reference SNP and flanking region in kb, example {--refsnp <your snp> --flank 500kb}
    # 2- A reference SNP and chromosome/start/stop specification {--refsnp <your snp> --chr # --start <base position> --end <base position> }
    # 3- A reference SNP and gene: {--refsnp <your snp> --refgene <your gene>}
    # 4- A gene and flanking region {--refgene <your gene> --flank 250kb }
    # 5- A gene and chromosome/start/stop specification { --refgene <your gene> --chr # --start <base position> --end <base position> }
    # 6- A chromosome/start/stop specification {--chr # --start <base position> --end <base position> }

###%%% --pop ASN --build hg19 --source 1000G_April2017 
bindir="/media/yagoubali/bioinfo2/pgwas/locuszoom/locuszoom/bin"



GWAS_summary=$1;
outdir=$2

mkdir -p ${outdir}
population=$3; #{AFR, AMR, ASN, EUR}
add_known_GWAS_variants=$4 ##{true, false}
type_of_region_to_plot=$5; #{{SNP_flanking}, {SNP_chromosome}, {SNP_gene}, {gene_flanking}, {gene_chromosome}, {chromosome}} 
 


plotting_region='';
if [[ ${type_of_region_to_plot} = "SNP_flanking" ]]; then
      SNP=$6; 
      flanking_region=$7;
      if [[ -z "$flanking_region" ]];then
          flanking_region=500;
          fi
     plotting_region="--refsnp $SNP \
     --flank ${flanking_region} "
elif [[ ${type_of_region_to_plot} = "SNP_chromosome" ]]; then
      SNP=$6; 
      chromosome=$7;
      plotting_region="--refsnp $SNP \
      --chr ${chromosome}  "
elif [[ ${type_of_region_to_plot} = "SNP_gene" ]]; then
      SNP=$6; 
      gene=$7;
      plotting_region="--refsnp $SNP \
      --refgene  ${gene} "
elif [[ ${type_of_region_to_plot} = "gene_flanking" ]]; then
      gene=$6;
      flanking_region=$7;
      if [[ -z "$flanking_region" ]];then
          flanking_region=500;
          fi
      plotting_region="--refgene  ${gene} \
      --flank ${flanking_region} "
elif [[ ${type_of_region_to_plot} = "gene_chromosome" ]]; then
       gene=$6;
       chromosome=$7;
       plotting_region="--refgene  ${gene} \
       --chr ${chromosome}  "
elif [[ ${type_of_region_to_plot} = "chromosome" ]]; then       

      chromosome=$6;
      chr_start=$7;
      chr_end=$8;
      plotting_region="--chr ${chromosome}  \
       --start ${chr_start} \
       --end ${chr_end}  "
else
 echo "Input errors"
 exit        
fi

gwas_catalog='';

if [[ ${add_known_GWAS_variants} = "true" ]]; then
  gwas_catalog="--gwas-cat whole-cat_significant-only  "
fi

###

#./locuszoom.sh Kathiresan_2009_HDL.txt ./SNP_flanking/ AFR  true SNP_flanking rs174546 500   #----> 1
#./locuszoom.sh Kathiresan_2009_HDL.txt  ./SNP_chromosome/ AFR true SNP_chromosome rs174546 11  #----> 2
#./locuszoom.sh Kathiresan_2009_HDL.txt  ./SNP_gene/ AFR  true SNP_gene rs17454 FADS1      #----> 3
#./locuszoom.sh Kathiresan_2009_HDL.txt  ./gene_flanking/   AFR true gene_flanking FADS1 500  #----> 4
#./locuszoom.sh Kathiresan_2009_HDL.txt  ./gene_chromosome/ AFR  true gene_chromosome FADS1 11  #----> 5
#./locuszoom.sh Kathiresan_2009_HDL.txt  ./chromosome/ AFR  true chromosome 11 61566596 61585029  #----> 6

set -x;	 
echo ${gwas_catalog} 
echo ${add_known_GWAS_variants}

python2 ${bindir}/locuszoom --metal ${GWAS_summary} ${plotting_region}  --pop ${population} --build hg19 --source 1000G_Nov2014  --plotonly --prefix ${outdir} ${gwas_catalog}

cd  ${outdir}
#mv _*/*pdf  plot.pdf
cp _*/*pdf  .

#--ld-measure dprime
#python2 ${bindir}/locuszoom --metal ${GWAS_summary} ${plotting_region}  --ld-vcf ${dbdir}/${population}.vcf.gz  ${gwas_catalog} --build hg19  --plotonly --prefix ${outdir}
