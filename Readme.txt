Software that needs to be installed (if any) with download and installation instructions.
=====
1. Install 'R':
	R may be installed either using steps given in tutorial OR by simply using : "sudo apt-get install r-base r-base-dev"
2  Install Pacakges neccessary to run script.
	a. From Terminal:
		-> sudo R --vanilla
		-> Follow all the substeps for 2.b
	b. From RStudio: Type the following commands into the console:
		->  install.packages('RCurl')
		->	install.packages('rJava')
		->	install.packages('bitops')
		->	install.packages('streamR')
		->	install.packages('RMOA')
		->	install.packages('ROAuth')
		->	install.packages('SnowballC')
		->	install.packages('stringr')
		->	install.packages('tm')

Environment variable settings (if any).
=====
There are no environment variable settings required.

Instructions on how to run the program.
=====
1) cd to the Twitter_Predict_R directory.
2) Run from Terminal: 
	-> "Rscript P3_Code.R"
3) Run from RStudio
	-> Select full file (using ctrl + a) then "ctrl + enter"

Files Included in the package.
=====
1. Readme.txt -> Contains instructions about how to run the R script and how to interpret results.
2. Generate_OAuth_Token.R -> R file that contains R script to authenticate twitter api credentials and set up stream.
3. P3_Code.R -> R file that contains the stream analytics code and is responsible for the trianing of the data set and generating results for the test set. Generate_OAuth_Token.R is sourced from this file and thus only this file needs to be run.
Instructions on how to interpret the results.
=====
<----------- TODO : Add this ----------------->

Sample input and output files (if applicable).
=====
<----------- TODO : Add this ----------------->

References to any software you may have used (if applicable).
=====
All software used was downloaded as per the tutorial and lab description. Links can be found in the PDFs.