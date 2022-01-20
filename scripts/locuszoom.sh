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

%%% --pop ASN --build hg19 --source 1000G_April2017 
bindir="/media/yagoubali/bioinfo2/pgwas/locuszoom/locuszoom/bin"
outdir="/media/yagoubali/bioinfo2/pgwas/locuszoom/locuszoom/outdir/"


##dbdir="/media/yagoubali/bioinfo2/pgwas/locuszoom/locuszoom/custom_1000G";    ---> not used
GWAS_summary=$1;
population=$2; #{AFR, AMR, ASN, EUR}
type_of_region_to_plot=$3; #{{SNP_flanking}, {SNP_chromosome}, {SNP_gene}, {gene_flanking}, {gene_chromosome}, {chromosome}} 
SNP=$4;  
gene=$5;
chromosome=$6;
chr_start=$7;
chr_end=$8;
flanking_region=$9;
add_known_GWAS_variants=${10} ##{true, false}


if [[ -z "$flanking_region" ]];then
    flanking_region=500;
fi

plotting_region='';
if [[ ${type_of_region_to_plot} = "SNP_flanking" ]]; then
     plotting_region="--refsnp $SNP \
     --flank ${flanking_region} "
elif [[ ${type_of_region_to_plot} = "SNP_chromosomeg" ]]; then
      plotting_region="--refsnp $SNP \
      --chr ${chromosome}  " #\
      #--start ${chr_start} \
      #--end ${chr_end}  "
elif [[ ${type_of_region_to_plot} = "SNP_gene" ]]; then
      plotting_region="--refsnp $SNP \
      --refgene  ${gene} "
elif [[ ${type_of_region_to_plot} = "gene_flanking" ]]; then
      plotting_region="--refgene  ${gene} \
      --flank ${flanking_region} "
elif [[ ${type_of_region_to_plot} = "gene_chromosomeg" ]]; then
       plotting_region="--refgene  ${gene} \
       --chr ${chromosome}  " #\
       #--start ${chr_start} \
       #--end ${chr_end}  "  
else
      plotting_region="--chr ${chromosome}  \
       --start ${chr_start} \
       --end ${chr_end}  "
fi

gwas_catalog='';
add_known_GWAS_variants="true"
if [[ ${add_known_GWAS_variants} = "true" ]]; then
  gwas_catalog="--gwas-cat whole-cat_significant-only  "
fi

###

#./locuszoom.sh Kathiresan_2009_HDL.txt  AFR gene_flanking snps FADS1 500
#--ld-measure dprime
#python2 ${bindir}/locuszoom --metal ${GWAS_summary} ${plotting_region}  --ld-vcf ${dbdir}/${population}.vcf.gz  ${gwas_catalog} --build hg19  --plotonly --prefix ${outdir}	 


python2 ${bindir}/locuszoom --metal ${GWAS_summary} ${plotting_region}  --pop ${population} --build hg19 --source 1000G_Nov2014  --plotonly --prefix ${outdir} ${gwas_catalog}

cd  ${outdir}
mv *pdf  plot.pdf
