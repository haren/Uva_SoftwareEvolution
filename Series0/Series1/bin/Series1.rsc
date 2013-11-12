module Series1

import lang::java::jdt::m3::AST;
import lang::java::jdt::m3::Core;
import analysis::m3::Core;
import analysis::m3::metrics::LOC;
import IO;
import Set;
import List;
import String;
import util::FileSystem;

int countLinesOfCode(M3 m3){				
	linesOfCode2 = countSourceLocPerLanguage(m3);	
	return linesOfCode2["java"];
}

//by Zarina E.
public list[loc] getJavaFiles (loc dir){
 return listJavaFiles = [ l | /file(l)  := crawl(dir), l.extension == "java"];
}

//by Zarina E.
public int countLineOfCodeInProject(loc project){
  int count = 0;
  int count_comments = 0;
  list[loc] allJavaFiles = getJavaFiles(project);
  multipleLineComments = false;
 
  for(content <- allJavaFiles){
          // List of all lines from certain .java file
   list[str]fileContent = readFileLines(content);
   
   for(i <- [0..size(fileContent)]){
                   //count all lines.
                   count +=1;

        //check for multiple line comments starter
       if(multipleLineComments==false && size(fileContent[i])>1 && 
           (startsWith(trim(fileContent[i]),"/*"))) {                      
                      multipleLineComments = true;
                      //println("Start, count: <count_comments> and content: <fileContent[i]>");
                       
       }

       // change state if multiple line comment ends. 
       if(size(fileContent[i])>0 && (startsWith(trim(fileContent[i]), "*/")||
        endsWith(trim(fileContent[i]), "*/"))) {
                       count_comments +=1;
                       multipleLineComments = false;
                       //println("End. count: <count_comments> and content <fileContent[i]>");
       }

       // Counts lines in multiple-line comments, empty lines and single line comments
       if (multipleLineComments == true || 
          startsWith(trim(fileContent[i]), "//") ||
          isEmpty(trim(fileContent[i]))) { 
        count_comments +=1; 
        //println("Inhoud: <fileContent[i]> and <count_comments>");
        }
   }
  }
  // total LOC minus counted lines of comments & empty lines
  return count - count_comments;
}

str computeRatingLinesOfCode(int count, ratingSchema){	
	println(count);
	if (count < ratingSchema["VERY_GOOD"]) {
		return "++";
	} else if (count < ratingSchema["GOOD"]) {
		return "+";
	} else if (count < ratingSchema["NEUTRAL"]) {
		return "o";
	} else if (count < ratingSchema["POOR"]) {
		return "-";
	} else {
		return "--";
	}
}

map[loc method, int count] countLinesOfCodePerMethod(M3 m3) {
	 map[loc, int] result = ();
	 	 
	 methodsList = methods(m3);
	 
	 for (method <- methodsList) {
	 	methodLoc = readFileLines(method);
	 	methodSloc = 0;
	 	multilineComment = false;
	 	
	 	for (methodLine <- methodLoc) {
	 		trimmedLine = trim(methodLine);
 		  	// todo: Move validation to a separate function
	 		if (size(trimmedLine) > 0 //filter out single lines
	 			//filter out single line comments 
	 			&& ((size(trimmedLine) > 1 && substring(trimmedLine,0,2) != "//") || size(trimmedLine) == 1)
	 			//filter out multiline comments
	 			&& !multilineComment) {
	 			// check if multiline comment is starting 
	 			if (size(trimmedLine) > 1 && substring(trimmedLine,0,2) == "/*") {
	 				multilineComment = true;
	 			}
	 			else {
	 				methodSloc += 1;
	 			}
	 		}
	 		if (multilineComment 
	 			&& (size(trimmedLine) > 1 && substring(trimmedLine,0,2) == "*/")){
	 			multilineComment = false;	 		
	 		}
	 	}	 	
	 	result[method] = methodSloc;
	 }
	 
	 return result;
}

str computeRatingLinesOfCodePerMethod(map[loc method, int count] methodLineCounts, treshold, ratingSchema){
	methodRatings = (
		"VERY_GOOD": 0,
		"GOOD": 0,
		"NEUTRAL": 0,
		"POOR": 0,
		"VERY_POOR": 0
	);
	//compute metric per method
	for (key <- methodLineCounts) {	
		if (methodLineCounts[key] < treshold["VERY_GOOD"]) {
			methodRatings["VERY_GOOD"] += 1;								
		} else if (methodLineCounts[key] < treshold["GOOD"]) {
			methodRatings["GOOD"] += 1;
		} else if (methodLineCounts[key] < treshold["NEUTRAL"]) {
			methodRatings["NEUTRAL"] += 1;			
		} else if (methodLineCounts[key] < treshold["POOR"]) {
			methodRatings["POOR"] += 1;			
			continue;	
		} else {
			methodRatings["VERY_POOR"] += 1;
		}		
	}
	
	//compute overal rating
	analyzedSum = 0.0;
	analyzedSum = methodRatings["VERY_GOOD"] 
		+ methodRatings["GOOD"] + methodRatings["NEUTRAL"] + methodRatings["POOR"] + methodRatings["VERY_POOR"];
		
	print("Unit sizes: ");println(methodRatings);

	if ((methodRatings["VERY_GOOD"]/analyzedSum * 100) > ratingSchema["VERY_GOOD"][0]
		&& ((methodRatings["VERY_GOOD"] + methodRatings["GOOD"])/analyzedSum * 100) > ratingSchema["VERY_GOOD"][1]
		&& ((methodRatings["VERY_GOOD"] + methodRatings["GOOD"] + methodRatings["NEUTRAL"])/analyzedSum * 100) > ratingSchema["VERY_GOOD"][2]
		&& ((methodRatings["VERY_GOOD"] + methodRatings["GOOD"] + methodRatings["NEUTRAL"] + methodRatings["POOR"])/analyzedSum * 100) > ratingSchema["VERY_GOOD"][3]) {
		return "++";
	} else if ((methodRatings["VERY_GOOD"]/analyzedSum * 100) > ratingSchema["GOOD"][0]
		&& ((methodRatings["VERY_GOOD"] + methodRatings["GOOD"])/analyzedSum * 100) > ratingSchema["GOOD"][1]
		&& ((methodRatings["VERY_GOOD"] + methodRatings["GOOD"] + methodRatings["NEUTRAL"])/analyzedSum * 100) > ratingSchema["GOOD"][2]
		&& ((methodRatings["VERY_GOOD"] + methodRatings["GOOD"] + methodRatings["NEUTRAL"] + methodRatings["POOR"])/analyzedSum * 100) > ratingSchema["GOOD"][3]) {
		return "+";
	} else if ((methodRatings["VERY_GOOD"]/analyzedSum * 100) > ratingSchema["NEUTRAL"][0]
		&& ((methodRatings["VERY_GOOD"] + methodRatings["GOOD"])/analyzedSum * 100) > ratingSchema["NEUTRAL"][1]
		&& ((methodRatings["VERY_GOOD"] + methodRatings["GOOD"] + methodRatings["NEUTRAL"])/analyzedSum * 100) > ratingSchema["NEUTRAL"][2]
		&& ((methodRatings["VERY_GOOD"] + methodRatings["GOOD"] + methodRatings["NEUTRAL"] + methodRatings["POOR"])/analyzedSum * 100) > ratingSchema["NEUTRAL"][3]) {
		return "o";
	} else if ((methodRatings["VERY_GOOD"]/analyzedSum * 100) > ratingSchema["POOR"][0]
		&& ((methodRatings["VERY_GOOD"] + methodRatings["GOOD"])/analyzedSum * 100) > ratingSchema["POOR"][1]
		&& ((methodRatings["VERY_GOOD"] + methodRatings["GOOD"] + methodRatings["NEUTRAL"])/analyzedSum * 100) > ratingSchema["POOR"][2]
		&& ((methodRatings["VERY_GOOD"] + methodRatings["GOOD"] + methodRatings["NEUTRAL"] + methodRatings["POOR"])/analyzedSum * 100) > ratingSchema["POOR"][3]) {
		return "-";
	} else {
		return "--";
	}
}

map[loc method, int complexity] computeCyclomaticComplexityPerMethod(M3 m3) {
	map[loc, int] result = ();

	methodsList = methods(m3);
	
	for (method <- methodsList) {
		cyclomaticComplexity = 1;
		
		methodTree = getMethodASTEclipse(method);
		
		visit(methodTree) {
			case \if(_,_) : cyclomaticComplexity += 1;
			case \if(_,_,_) : cyclomaticComplexity += 1;
			case \do(_,_) : cyclomaticComplexity += 1;
			case \foreach(_,_,_): cyclomaticComplexity += 1;
			case \for(_,_,_): cyclomaticComplexity += 1;
			case \for(_,_,_,_): cyclomaticComplexity += 1;	
			case \switch(_,_): cyclomaticComplexity += 1;
			case \while(_,_): cyclomaticComplexity += 1;
		}
		result[method] = cyclomaticComplexity;		
	 }
	
	return result;
}

str computeRatingCyclomaticComplexityPerMethod(map[loc method, int count] methodComplexities, treshold, ratingSchema){
	methodRatings = (
		"NO_RISK": 0,
		"MODERATE_RISK": 0,
		"HIGH_RISK": 0,
		"VERY_HIGH_RISK": 0
	);	
	
	//compute metric per method
	for (key <- methodComplexities) {	
		if (methodComplexities[key] < treshold["NO_RISK"]) {
			methodRatings["NO_RISK"] += 1;								
		} else if (methodComplexities[key] < treshold["MODERATE_RISK"]) {
			methodRatings["MODERATE_RISK"] += 1;
		} else if (methodComplexities[key] < treshold["HIGH_RISK"]) {
			methodRatings["HIGH_RISK"] += 1;			
		} else {
			methodRatings["VERY_HIGH_RISK"] += 1;
		}		
	}
	
	CYCLOMATIC_COMPLEXITY_RATING_SCHEMA = (
		// RANK : [MODERATE_RISK %, HIGH_RISK %, VERY_HIGH_RISK %]
		"VERY_GOOD": [25, 0, 0],
		"GOOD": [30, 5, 0],
		"NEUTRAL": [40, 10, 0],
		"POOR": [50, 15, 5]
	);
	
	//compute overal rating
	analyzedSum = 0.0;
	analyzedSum = methodRatings["NO_RISK"] 
		+ methodRatings["MODERATE_RISK"] + methodRatings["HIGH_RISK"] + methodRatings["VERY_HIGH_RISK"];
		
	print("Complexity per unit: ");println(methodRatings);
	
	if (((methodRatings["MODERATE_RISK"])/analyzedSum * 100) <= ratingSchema["VERY_GOOD"][0]
		&& (methodRatings["HIGH_RISK"]/analyzedSum * 100) <= ratingSchema["VERY_GOOD"][1]
		&& (methodRatings["VERY_HIGH_RISK"]/analyzedSum * 100) <= ratingSchema["VERY_GOOD"][1]) {
		return "++";
	} else if (((methodRatings["MODERATE_RISK"])/analyzedSum * 100) <= ratingSchema["GOOD"][0]
		&& (methodRatings["HIGH_RISK"]/analyzedSum * 100) <= ratingSchema["GOOD"][1]
		&& (methodRatings["VERY_HIGH_RISK"]/analyzedSum * 100) <= ratingSchema["GOOD"][1]) {
		return "+";
	} else if (((methodRatings["MODERATE_RISK"])/analyzedSum * 100) <= ratingSchema["NEUTRAL"][0]
		&& (methodRatings["HIGH_RISK"]/analyzedSum * 100) <= ratingSchema["NEUTRAL"][1]
		&& (methodRatings["VERY_HIGH_RISK"]/analyzedSum * 100) <= ratingSchema["NEUTRAL"][1]) {
		return "o";
	} else if (((methodRatings["MODERATE_RISK"])/analyzedSum * 100) <= ratingSchema["POOR"][0]
		&& (methodRatings["HIGH_RISK"]/analyzedSum * 100) <= ratingSchema["POOR"][1]
		&& (methodRatings["VERY_HIGH_RISK"]/analyzedSum * 100) <= ratingSchema["POOR"][1]) {
		return "-";
	} else {
		return "--";
	}
}

void computeMetrics(){

	//OVERALL RESULT
	// volume, complexity per unit, duplication, unit size, unit testing
	overallRating = (
		"VOLUME" : "",
		"COMPLEXITY_PER_UNIT": "",
		"DUPLICATION" : "",
		"UNIT_SIZE" : "",
		"UNIT_TESTING" : ""
	);

	//GLOBALS
	VOLUME_TRESHOLD_VALUES = (
		"VERY_GOOD": 66000,
		"GOOD": 246000,
		"NEUTRAL": 665000,
		"POOR": 1310000
		//"VERY_POOR"			
	);
	
	
	CYCLOMATIC_COMPLEXITY_TRESHOLD_VALUES = (
		"NO_RISK": 10,
		"MODERATE_RISK": 20,
		"HIGH_RISK": 50
		//"VERY_HIGH_RISK"
	);
	
	CYCLOMATIC_COMPLEXITY_RATING_SCHEMA = (
		// RANK : [MODERATE_RISK %, HIGH_RISK %, VERY_HIGH_RISK %]
		"VERY_GOOD": [25, 0, 0],
		"GOOD": [30, 5, 0],
		"NEUTRAL": [40, 10, 0],
		"POOR": [50, 15, 5]
	);
	
	UNIT_SIZE_TRESHOLD_VALUES = (
		"VERY_POOR": 500,
		"POOR": 300,
		"NEUTRAL": 100,
		"GOOD": 30,
		"VERY_GOOD": 10
	);
	
	UNIT_SIZE_RATING_SCHEMA = (
		// RANK : [VERY_GOOD %, GOOD %, NEUTRAL %, BAD %, VERY_BAD%]
		"VERY_GOOD": [50, 40, 10, 0, 0],
		"GOOD": [30, 40, 30, 0, 0],
		"NEUTRAL": [30, 40, 30, 0, 0],
		"POOR": [10, 30, 50, 10, 0]
	);
	
	projectLocation = |project://test_java_project|;
	projectTree = createM3FromEclipseProject(projectLocation);
	
	projectLocation = |project://smallsql0.21_src|;
	projectTree = createM3FromEclipseProject(projectLocation);
	//
	//projectLocation = |project://hsqldb-2.3.1|;
	//projectTree = createM3FromEclipseProject(projectLocation);
		
	// compute LOC - write your own method?
	//testProjectLOC = countLinesOfCode(testProjectTree);	
	testProjectLOC = countLineOfCodeInProject(projectLocation);	
	overallRating["VOLUME"] = 
		computeRatingLinesOfCode(testProjectLOC, VOLUME_TRESHOLD_VALUES);
		
	//smallSqlProjectLOC = countLinesOfCode(smallSqlProjectLocation);	
	//print("Small sql project: "); println(smallSqlProjectLOC);
	
	//hsqldbProjectLOC = countLinesOfCode(hsqldbProjectLocation);	
	//print("Hsqldb project: "); println(hsqldbProjectLOC);
	
	//compute loc rating 
	
	// compute complexity per unit
	//todo LH:build an ast tree
	//visit case \if
	cyclomaticResult = computeCyclomaticComplexityPerMethod(projectTree);
	overallRating["COMPLEXITY_PER_UNIT"] = 
		computeRatingCyclomaticComplexityPerMethod(cyclomaticResult, CYCLOMATIC_COMPLEXITY_TRESHOLD_VALUES, CYCLOMATIC_COMPLEXITY_RATING_SCHEMA);
		
	//astTree = createAstsFromEclipseProject(testProjectLocation, true);
	//println(astTree);
	
	//compute complexity rating
	
	//compute duplication
	
	//compute duplication rating
	
	// compute unit size (LOC / unit)	
	locResult = countLinesOfCodePerMethod(projectTree);
	//countLinesOfCodePerMethod(smallSqlProjectTree);
	//countLinesOfCodePerMethod(hsqldbProjectTree);
	//compute unit size rating
	overallRating["UNIT_SIZE"] = 
		computeRatingLinesOfCodePerMethod(locResult, UNIT_SIZE_TRESHOLD_VALUES, UNIT_SIZE_RATING_SCHEMA);		
		
	
	//print general results
	for (key <- overallRating) {
		println("<key>: <overallRating[key]>");
	}	
}