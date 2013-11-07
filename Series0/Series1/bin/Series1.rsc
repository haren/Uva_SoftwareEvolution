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

map[str method, int count] countLinesOfCodePerMethod(M3 m3) {
	 map[str, int] result = ();
	 	 
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
	 	print(method); print(": "); println(methodSloc);
	 }
	 
	 return result;
}


void computeMetrics(){
	UNIT_SIZE_TRESHOLD_VALUES = (
		"VERY_POOR": 500,
		"POOR": 300,
		"NEUTRAL": 100,
		"GOOD": 30,
		"VERY_GOOD": 10
	);
	
	testProjectLocation = |project://test_java_project|;
	testProjectTree = createM3FromEclipseProject(testProjectLocation);
	
	//smallSqlProjectLocation = |project://smallsql0.21_src|;
	//smallSqlProjectTree = createM3FromEclipseProject(smallSqlProjectLocation);
	
	//hsqldbProjectLocation = |project://hsqldb-2.3.1|;
	//hsqldbProjectTree = createM3FromEclipseProject(hsqldbProjectLocation);
	
	// compute LOC - write your own method?
	//testProjectLOC = countLinesOfCode(testProjectTree);
	//print("Test project: "); println(testProjectLOC);
		
	//smallSqlProjectLOC = countLinesOfCode(smallSqlProjectLocation);	
	//print("Small sql project: "); println(smallSqlProjectLOC);
	
	//hsqldbProjectLOC = countLinesOfCode(hsqldbProjectLocation);	
	//print("Hsqldb project: "); println(hsqldbProjectLOC);
	
	// compute complexity per unit
	
	// compute duplication
	
	// compute unit size (LOC / unit)	
	countLinesOfCodePerMethod(testProjectTree);	
}
