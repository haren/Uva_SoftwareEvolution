module Series2

import vis::Figure;
import vis::FigureSWTApplet;
import vis::ParseTree;
import vis::Render;
import Series1;
import Series2_Zarina;
import IO;
import Set;
import List;
import String;
import util::FileSystem;
import Type;
import vis::KeySym;

public int computeOverallProjectScore(map[str,str] sigScores, map[str, list[int]] colors) {
	r = 0;
	g = 0;
	b = 0;
	projectScore = "o";
	length = 0;
	
	for (key <- sigScores) {
		length += 1;		
		r += colors[sigScores[key]][0];
		g += colors[sigScores[key]][1];
		b += colors[sigScores[key]][2];			
	}
	
	r /= length;
	g /= length;
	b /= length;
	 	
	return rgb(r,g,b);
}

 public FProperty renderGeneralProjectsTreeOnClick(list[Figure] titles){ 	
	return onMouseDown(bool (int butnr, map[KeyModifier,bool] modifiers) {			
		renderGeneralProjectsTree(titles);		
		return true;
	});
 }

public void renderGeneralProjectsTree(list[Figure] titles){
	render(
		tree(titles[0], 
		[
			titles[1],
			titles[2],
			titles[3]				
		], 
		gap(50))
	);
}

public void renderProjectDetaisTree(Figure titleBox, list[Figure] boxes){
	render(
		tree(titleBox, boxes, gap(50))		
	);
}

 public FProperty mouseOverInfo(str S, Color color){
	return mouseOver(
		box(text(S), fillColor(color), resizable(false), grow(1.5))
	);
 }
 
 public FProperty mouseClick(Figure titleBox, list[Figure] boxes){
	return onMouseDown(bool (int butnr, map[KeyModifier,bool] modifiers) {		
		renderProjectDetaisTree(titleBox, boxes);
		return true;
	});
 }
 
 public void renderPack (list[Figure] boxes) {
 	render(pack(boxes, gap(5)));
 }
 
 public void prepareFileTypeBoxes (map[str, int] fileTypes){
 	boxes = [];
 	i = 79;
 	
 	//get max size
 	maxSize = 0;
 	for (key <- [k | k <- fileTypes]) {
 		if (fileTypes[key] > maxSize) {
 			maxSize = fileTypes[key];
 		}
 	} 
 	
 	for (key <- [k | k <- fileTypes]) {
 		i += 79;
 		fontNewSize = 15;
 		
 		boxSize = 500 * fileTypes[key] / maxSize;
 		if (boxSize < 10) {
 			boxSize = 10;
 			fontNewSize = 10;
 		}
 		
 		boxes += box(			
			text("<key>", fontSize(fontNewSize)), fillColor(rgb((boxSize + i)%255, ((boxSize + i) / 2)%255, ((boxSize + i) / 3)%255)), size(boxSize, boxSize), resizable(false)
		);
 	}
 	renderPack(boxes);
 }
 
public void main(){	
	/*
		GLOBALS
	*/	
	
	testProjectFileTypes = ("classpath":1,"project":1,"class":1,"java":1,"prefs":1);
	
	smallSqlProjectFileTypes =  ("classpath":1,"jar":1,"project":1,"class":196,"java":186,"txt":2,"prefs":1);
	
	hsqldbProjectFileTypes = ("pl":1,"cmd":10,"flex":2,"php":1,"class":742,"properties":36,"pdf":2,"rc":2,"txt":91,"prefs":1,"text":70,"ddl":3,"html":201,"png":44,"svg":48,"cfg":4,"c":1,"xhtml":1,"java":547,"zip":1,"nsql":6,"list":1,"classpath":1,"inter":5,"jar":10,"project":1,"bnd":1,"xml":17,"bat":6,"bash":2,"tif":5,"xsl":5,"setting":1,"init":2,"groovy":3,"plist":1,"sql":72,"py":2,"gradle":5,"dsv":12,"csv":1,"isql":6,"gif":48,"css":2,"":3);
		
	COLORS = (
		"++": rgb(0,153,0), //green
		"+": rgb(128,255,0), //light green
		"o": rgb(255,255,102), //yellow
		"-": rgb(255,128,0), //orange
		"--": rgb(255,0,0) //red
	);
	
	COLORS_ARRAY = (
		"++": [0,153,0], //green
		"+": [128,255,0], //light green
		"o": [255,255,102], //yellow
		"-": [255,128,0], //orange
		"--": [255,0,0] //red
	);
	
	
	/*
		FUNCTIONALITY CODE
	*/
	overallRating_testProject = (
		"DUPLICATION": "+",
		"UNIT_SIZE": "+",
		"VOLUME": "++",
		"COMPLEXITY_PER_UNIT": "++"
	);
	
	exactValues_testProject = (
		"DUPLICATION": "8.82352941200%",
		"UNIT_SIZE": "GOOD: 2,\nVERY_POOR : 0,\nNEUTRAL : 0,\nVERY_GOOD : 1,\nPOOR : 0",
		"VOLUME": "Lines of code: 34",
		"COMPLEXITY_PER_UNIT": "NO_RISK : 3,\nHIGH_RISK : 0,\nMODERATE_RISK : 0,\nVERY_HIGH_RISK : 0)"
	);
	
	overallRating_smallSql = (
		"DUPLICATION": "o",
		"UNIT_SIZE": "+",
		"VOLUME": "++",
		"COMPLEXITY_PER_UNIT": "++"
	);
	
	exactValues_smallSql = (
		"DUPLICATION": "11.5440595500%",
		"UNIT_SIZE": "GOOD: 381,\nVERY_POOR : 1,\nNEUTRAL : 111,\nVERY_GOOD : 1899,\nPOOR : 8",
		"VOLUME": "Lines of code: 24047",
		"COMPLEXITY_PER_UNIT": "NO_RISK : 2308,\nHIGH_RISK : 27,\nMODERATE_RISK : 63,\nVERY_HIGH_RISK : 2"
	);
	
	overallRating_hsqldb = (
		"DUPLICATION": "o",
		"UNIT_SIZE": "+",
		"VOLUME": "+",
		"COMPLEXITY_PER_UNIT": "--"
	);
	
	exactValues_hsqldb = (
		"DUPLICATION": "9.12310595500%",
		"UNIT_SIZE": "NO_RISK : 10172,\nHIGH_RISK : 149,\nMODERATE_RISK : 510,\nVERY_HIGH_RISK : 29",
		"VOLUME": "Lines of code: 172331",
		"COMPLEXITY_PER_UNIT": "NO_RISK : 6932,\nHIGH_RISK : 1242,\nMODERATE_RISK : 1555,\nVERY_HIGH_RISK : 1078"
	);
	
	boxesTestProject = [];
	boxesSmallSql = [];	
	boxesHsqldb = [];
		
	// prepare boxes
	for (key <- overallRating_testProject) {
		boxesTestProject += box(			
			text("<key>"),left(),top(), fillColor(COLORS[overallRating_testProject[key]]),shrink(0.1),
			mouseOverInfo(exactValues_testProject[key], rgb(255,255,255)), gap(50)
		);				
	}
	for (key <- overallRating_smallSql) {
		boxesSmallSql += box(
			text("<key>"),left(),top(),fillColor(COLORS[overallRating_smallSql[key]]),shrink(0.4), 
			mouseOverInfo(exactValues_smallSql[key], rgb(255,255,255)), gap(50)
		);				
	}
	for (key <- overallRating_hsqldb) {
		boxesHsqldb += box(
			text("<key>"),left(),top(),fillColor(COLORS[overallRating_hsqldb[key]]),shrink(0.4),
			mouseOverInfo(exactValues_hsqldb[key], rgb(255,255,255)), gap(50)
		);				
	}
	
	titles = [];
		
	titles = [
		box(text("Projects"), fillColor("white"),shrink(0.4), resizable(false), gap(50)),
		
		box(text("Test project"), fillColor(computeOverallProjectScore(overallRating_testProject, COLORS_ARRAY)), shrink(0.1), 
			mouseOverInfo("Click for details", rgb(255,255,255)), resizable(false), gap(50), 
			mouseClick(
				box(text("Test project"), fillColor(computeOverallProjectScore(overallRating_testProject, COLORS_ARRAY)), shrink(0.4), gap(50), 
					renderGeneralProjectsTreeOnClick(titles), mouseOverInfo("Go back", rgb(255,255,255))
				), boxesTestProject)
			),
			
		box(text("Small sql"), fillColor(computeOverallProjectScore(overallRating_smallSql, COLORS_ARRAY)),shrink(0.1), 
			mouseOverInfo("Click for details", rgb(255,255,255)), resizable(false), gap(50), mouseClick(box(text("Small sql"), 
			fillColor(computeOverallProjectScore(overallRating_testProject, COLORS_ARRAY)), shrink(0.4), gap(50)), boxesSmallSql)),
			
		box(text("Hsqldb"), fillColor(computeOverallProjectScore(overallRating_hsqldb, COLORS_ARRAY)),shrink(0.1), 
			mouseOverInfo("Click for details", rgb(255,255,255)), resizable(false), gap(50), mouseClick(box(text("Hsqldb"), 
			fillColor(computeOverallProjectScore(overallRating_testProject, COLORS_ARRAY)), shrink(0.4), gap(50)), boxesHsqldb))	
	];
	
	mainMap = treemap([
		box(text("SIG Metrics (All)", fontSize(15)), shrink(0.8),area(30),fillColor("lightgreen"),
			mouseOverInfo("Click for details", rgb(255,255,255)),
			onMouseDown(bool (int butnr, map[KeyModifier,bool] modifiers) {
				renderGeneralProjectsTree(titles);
				return true;
			})
		),
        box(vcat([
            	text("Classes and methods"),
            	treemap([
            		box(text("Test Project"), area(5), fillColor("purple")),
            		box(text("Small sql"), area(10), fillColor("orange")),
            		box(text("Hsqldb"),area(15), fillColor("green"))
        		])
            ],shrink(0.8)),area(30),fillColor("lightblue")),
	    box(vcat([
            	text("File types"),
            	treemap([
            		box(text("Test Project"), area(5), fillColor("purple")),
            		box(text("Small sql"), area(10), fillColor("orange")),
            		box(text("Hsqldb"),area(15), fillColor("green"))
        		])
            ],shrink(0.8)),area(30),fillColor("lightblue"))
	]);
	
	render(mainMap);			
}
