module Series1

import lang::java::jdt::m3::AST;
import lang::java::jdt::m3::Core;
import analysis::m3::Core;
import analysis::m3::metrics::LOC;
import IO;
import Set;
import List;
import String;

int countLinesOfCode(M3 m3){				
	linesOfCode2 = countSourceLocPerLanguage(m3);	
	return linesOfCode2["java"];
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
	
	print("method ratings: "); println(methodRatings);
	
	//compute overal rating
	analyzedSum = methodRatings["VERY_GOOD"] 
		+ methodRatings["GOOD"] + methodRatings["NEUTRAL"] + methodRatings["POOR"] + methodRatings["VERY_POOR"];
		
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
		
		//visit(methodTree) {
		//	case \if : println("MAMY IFA");
		//	case \for : println("Mamygo!");
		//}
		
		result[method] = cyclomaticComplexity;
		
	 	//methodLines = readFileLines(method);
	 	//	
	 	//for (methodLine <- methodLines) {
	 	//	trimmedLine = trim(methodLine);
 		//  	if (contains(trimmedLine, "for")) {
 		//  		cyclomaticComplexity += 1;	
 		//  	} else if (contains(trimmedLine, "if")) { 		  	
 		//  		cyclomaticComplexity += 1;
 		//  	} else if (contains(trimmedLine, "case")) { 		  	
 		//  		cyclomaticComplexity += 1;
 		//  	} else if (contains(trimmedLine, "do")) { 		  	
 		//  		cyclomaticComplexity += 1;
 		//  	}
	 	//}
	 	print(method); print(": "); println(cyclomaticComplexity); 
	 	
	 }
	
	return result;
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
	
	testProjectLocation = |project://test_java_project|;
	testProjectTree = createM3FromEclipseProject(testProjectLocation);
	
	smallSqlProjectLocation = |project://smallsql0.21_src|;
	smallSqlProjectTree = createM3FromEclipseProject(smallSqlProjectLocation);
	//
	//hsqldbProjectLocation = |project://hsqldb-2.3.1|;
	//hsqldbProjectTree = createM3FromEclipseProject(hsqldbProjectLocation);
	
	// compute LOC - write your own method?
	//testProjectLOC = countLinesOfCode(testProjectTree);
	//print("Test project: "); println(testProjectLOC);
		
	//smallSqlProjectLOC = countLinesOfCode(smallSqlProjectLocation);	
	//print("Small sql project: "); println(smallSqlProjectLOC);
	
	//hsqldbProjectLOC = countLinesOfCode(hsqldbProjectLocation);	
	//print("Hsqldb project: "); println(hsqldbProjectLOC);
	
	//compute loc rating 
	
	// compute complexity per unit
	//todo LH:build an ast tree
	//visit case \if
	//cyclomaticResult = computeCyclomaticComplexityPerMethod(testProjectTree);
		
	//astTree = createAstsFromEclipseProject(testProjectLocation, true);
	//println(astTree);
	
	//compute complexity rating
	
	//compute duplication
	
	//compute duplication rating
	
	// compute unit size (LOC / unit)	
	locResult = countLinesOfCodePerMethod(smallSqlProjectTree);
	overallRating["UNIT_SIZE"] = computeRatingLinesOfCodePerMethod(locResult, UNIT_SIZE_TRESHOLD_VALUES, UNIT_SIZE_RATING_SCHEMA);	
	//countLinesOfCodePerMethod(smallSqlProjectTree);
	//countLinesOfCodePerMethod(hsqldbProjectTree);	
	
	//compute unit size rating
	
	//print general results
	for (key <- overallRating) {
		println("<key>: <overallRating[key]>");
	}	
}