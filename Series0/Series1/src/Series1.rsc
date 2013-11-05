module Series1

import lang::java::jdt::m3::AST;
import lang::java::jdt::m3::Core;
import analysis::m3::Core;
import analysis::m3::metrics::LOC;
import IO;
import Set;
import List;

int countLinesOfCode(M3 m3){				
	linesOfCode2 = countSourceLocPerLanguage(m3);	
	return linesOfCode2["java"];
}

list[str] filterOutEmptyAndCommentLines(list[str] lines){
	//TODO : filter out empty lines and comments
	return lines;
}

map[str method, int count] countLinesOfCodePerMethod(M3 m3) {
	 map[str, int] result = ();
	 	 
	 methodsList = methods(m3);
	 
	 for (method <- methodsList) {
	 	methodLoc = size(readFileLines(method));
	 	//filter out empty lines
	 	print(method); print(": "); println(methodLoc);
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