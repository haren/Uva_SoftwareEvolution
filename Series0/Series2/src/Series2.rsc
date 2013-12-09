module Series2

import vis::Figure;
import vis::FigureSWTApplet;
import vis::ParseTree;
import vis::Render;
import Series1;
import IO;
import Set;
import List;
import String;
import util::FileSystem;
import Type;

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

public void renderGeneralProjectsTree(list[Figure] titles){
	render(
		tree(titles[0], 
		[
			titles[1],
			titles[2],
			titles[3]				
		], 
		std(gap(50)))
	);
}

 public FProperty mouseOverInfo(str S, Color color){
	return mouseOver(
		box(text(S), fillColor(color), width(100), height(10))
	);
 }
 
 public FProperty mouseClick(str S, Color color){
	return mouseOver(
		box(text(S), fillColor(color), size(10))
	);
 }
 
public void main(){	
	/*
		GLOBALS
	*/
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
	
	overallRating_smallSql = (
		"DUPLICATION": "o",
		"UNIT_SIZE": "+",
		"VOLUME": "++",
		"COMPLEXITY_PER_UNIT": "++"
	);
	
	overallRating_hsqldb = (
		"DUPLICATION": "o",
		"UNIT_SIZE": "--",
		"VOLUME": "+",
		"COMPLEXITY_PER_UNIT": "++"
	);

		
	titles = [
		box(text("Projects"), fillColor("white"),shrink(0.4)),
		box(text("Test project"), fillColor(computeOverallProjectScore(overallRating_testProject, COLORS_ARRAY)),shrink(0.1), mouseOverInfo("Click for details", rgb(255,255,255))),
		box(text("Small sql"), fillColor(computeOverallProjectScore(overallRating_smallSql, COLORS_ARRAY)),shrink(0.1), mouseOverInfo("Click for details", rgb(255,255,255))),
		box(text("Hsqldb"), fillColor(computeOverallProjectScore(overallRating_hsqldb, COLORS_ARRAY)),shrink(0.1), mouseOverInfo("Click for details", rgb(255,255,255)))		
	];	
	
	boxesTestProject = [];
	boxesSmallSql = [];	
	boxesHsqldb = [];
		
	// prepare boxes
	for (key <- overallRating_testProject) {
		boxesTestProject += box(text("<key>"),left(),top(),fillColor(COLORS[overallRating_testProject[key]]),shrink(0.4));				
	}
	for (key <- overallRating_smallSql) {
		boxesSmallSql += box(text("<key>"),left(),top(),fillColor(COLORS[overallRating_smallSql[key]]),shrink(0.4));				
	}
	for (key <- overallRating_hsqldb) {
		boxesHsqldb += box(text("<key>"),left(),top(),fillColor(COLORS[overallRating_hsqldb[key]]),shrink(0.4));				
	}
	
	renderGeneralProjectsTree(titles);
	
	//render(
	//	tree(titles[0], 
	//	[
	//		tree(titles[1], boxesTestProject, std(gap(50))),
	//		tree(titles[2], boxesSmallSql, std(gap(50))),
	//		tree(titles[3], boxesHsqldb, std(gap(50))),
	//		tree(titles[3], [(pack(boxesHsqldb, std(gap(50))))], std(gap(50)))		
	//	], 
	//	std(gap(50)))
	//);
			
}
