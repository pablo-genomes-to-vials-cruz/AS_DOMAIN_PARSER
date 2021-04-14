##################################################################################
# AS_domain_parser_folder.pl
# by Pablo Cruz-Morales april 13 2021 
# A simple parser to extract all the antismash annotated files in a cute table 
# place it into the folder with folders of antismash 5 outputs and obtain a table 
# use: $pablo perl AS_domain_parser_folder.pl 
# output goes into the STDOUT
# output structure: 
# Folder name locus_tag region_product  AA_seq Domain monomers
# VIVA LA PERL!!!
###################################################################################



@folders=`ls -d */`;
foreach(@folders){
	chomp $_;
	$foldername="$_";
	$foldername=~s/\///;
	@files=`ls \.\/$_\*region\*.gbk`;
	foreach(@files){
	@domainstring=();
	@regionarray=();
	open FILE, $_ or die "give me an input\n";
	while ($line=<FILE>){
		if ($line=~/     gene            /.. $line=~/     CDS             /){
		$flag=1;
		#printing the domains from the last loop
			if (scalar @domainarray > 0){
				$domainstring = join( '-', @domainarray );
				@domainarray=();
				print "\t$domainstring";
			}
			if (scalar @extenderarray > 0){
				$extenderstring = join( '-', @extenderarray );
				@extenderarray=();
				print "\t$extenderstring";
			}
		#gets locus tags
			if ($line=~/\/locus_tag/){
				$locus="$line";
				$locus=~s/\s+\/locus_tag="//;
				$locus=~s/"//;
				chomp $locus;
				if ($flag==1){
					print "\n$foldername\t$locus\t$regionnumber\_$product\t";
				}
			}
		}#end of gene to CDS
		#gets proteins
		if($line=~/                     \/translation\=\"[ARNDCEQGHILKMFPSTWYV]+/ or $line=~m/^                     [A-Z \W]+$/ or $line=~/                     \/translation\=\"[ARNDCEQGHILKMFPSTWYV]+\"/){
			$sequence="$line";
			$sequence=~s/\s+//g;
			$sequence=~s/\/translation\=\"//;
			$sequence=~s/\"//;
			chomp $sequence;
			if ($sequence=~/\"/){
				$sequence="";
			}
			if ($flag==1){
				print "$sequence";
			}
		}#end of proteins
	#gets SMILES and gets them out of the way 
		if ($line=~/     cand\_cluster   /.. $line=~/     region          /){
			if ($line=~/\/SMILES\=/){
			$smile="$line";
			$smile=~s/\s+\/SMILES\=\"//;
			$smile=~s/"//;
			chomp $smile;
			#print "$smile\n";
			}
		}#smiles	
	#get pfam domains and keep them away 
		if ($line=~/     PFAM_domain     /..$line=~/                     \/tool\=\"antismash\"/){ 
			$flag=0;
		}#pfam  
	#get asdomains and specificity
		if ($line=~/     aSDomain        /..$line=~/                     \/tool\=\"antismash\"/){ 
		$flag=0;
			if ($line=~/                     \/aSDomain\=\"/){
				$asdomain="$line";			
				$asdomain=~s/\/aSDomain\=\"//;
				$asdomain=~s/\"//;
				$asdomain=~s/\s+//;
				$asdomain=~s/PKS_Docking_Cterm/Dock_C/;
				$asdomain=~s/PKS_Docking_Nterm/Dock_N/;
				$asdomain=~s/PKS_//;
				chomp $asdomain;
				push(@domainarray, $asdomain);
			}
			if ($line=~/\/specificity\=\"consensus\:/){
				$extender="$line";
				$extender=~s/\/specificity\=\"consensus\://;
				$extender=~s/\"//;
				$extender=~s/\s+//g;		
				chomp $extender;
				push(@extenderarray, $extender);
			}
		}#from ASdomains
		if ($line=~/     region          /..$line=~/                     \/region\_number\=\"/){ 
			if ($line=~/\/product\=\"/g){
				$regionproduct="$line";
				$regionproduct=~s/\/product\=\"//;
				$regionproduct=~s/\"//;
				$regionproduct=~s/\s+//g;		
				push(@regionarray, $regionproduct);
				$product = join( '-', @regionarray );
			}
			if ($line=~/\/region\_number\=\"/g){
				$regionnumber="$line";
				$regionnumber=~s/\/region\_number\=\"//;
				$regionnumber=~s/\"//;
				$regionnumber=~s/\s+//g;		
				chomp $regionnumber;
			}
		}#region
	}#from while	
	print "\t@domainstring";

	


	}#close penultimate loop, files
}#close first loop, folder



close;
