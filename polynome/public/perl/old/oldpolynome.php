<?

# if we received a new form submission then process it and start the job
if ( $_POST["formname"] == "newjob" ) {

        # Assign form variables to regular php variables
        $name = $_POST["name"];
    	$n_nodes = $_POST["n_nodes"];
    	$data_type = $_POST["data_type"];
    	$model_type = $_POST["model_type"];

    	# each of these is a string.    	
    	$datafile = $_FILES['wtfile1']['tmp_name'];
    	$infofile = $_FILES['wtfile2']['tmp_name'];

        # create an id for the results file to be named
        # This needs to be unique so other users don't step on each other

        $now = date(YmdHis);
#       $random = rand(0,999);
#        $min_file = "$now-$random.txt";     # m2 input file
        $min_file = "$now.txt";              # m2 input file
#        $min_file = "test.txt";         # for testing purposes


system("M2 Discretize.m2 --silent -q -e \"discretize({\"$datafile\"},2);exit 0;\"");
#system("M2 Discretize.m2 --silent -q -e \"discretize({\"toy.txt\"},2);exit 0;\"");



        # execute the analysis application
        # you should pass the parameters to the app here and make sure that
        # the app is putting the output in $output_file(=$min_file)
        # also note that, if the app is going to populate this file over
        # time, it might be better to output to a temp file and then move
        # that temp file to $output_file so that people don't retrieve
        # an incomplete file.  The results getter below simply looks for
        # $output_file, and if it exists, it returns it
        # system("/home/dmachi/test_script.sh $output_file $name");


}

# If there wasn't a form submitted and we aren't requesting results, then Print out sample submission form

include("polynome.html");
?>

