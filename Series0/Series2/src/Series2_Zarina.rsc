module Series2_Zarina

import vis::Figure;
import vis::Render;
import Prelude;
import vis::KeySym;
import lang::java::m3::AST;
import lang::java::m3::Core;
import lang::java::jdt::m3::Core;
import lang::java::jdt::m3::AST;
import util::FileSystem;
import util::Editors;
import lang::java::m3::Registry;
import Set;
import Map;
import String;

import Series1; 

public M3 model(loc location) {
	M3 model = createM3FromEclipseProject(location);
	return model;
}

// All methodes in the project.
public set[loc] methods(loc project) {
	M3 model = model(project);
	return methods(model);
}

public set[loc] packages(loc project) {
	M3 model = model(project);
	return packages(model);
}


public map[loc,int] methodsPerClass(loc location) {
	myModel = model(location);
	int numberOfMethods(loc cl, M3 model) = size([ m | m <- model@containment[cl], isMethod(m)]);
	map[loc class, int methodCount] numberOfMethodsPerClass = 
	(cl:numberOfMethods(cl, myModel) | <cl,_> <- myModel@containment, isClass(cl));
	return numberOfMethodsPerClass;
}	

public set[loc] methodsOfThatClass(loc class, loc project) {
  M3 myModel = model(project);
  set[loc] methods = toSet([ e | e <- myModel@containment[class], e.scheme == "java+method"]);
  return methods;
}

// Count just all lines... in methods (todo: comments & empty lines has to be filtered out.)
// To be used other method, made by Lukasz or to be modified.
public int countLinesMethods(loc method) {
  int count = 0;
   for(i <-[0..size(readFileLines(method))]){
     count +=1;
   }
   return count;  
}
// ------ Series 2


//Boxes paradise 
public void drawClassMap(loc project) {
  M3 myModel = model(project);
  list[loc] allPackages = toList(packages(myModel));
  map[loc method, int count] methodsInClass = methodsPerClass((project));
  map[loc method, int count] ccPerMethod = computeCyclomaticComplexityPerMethod(createM3FromEclipseProject(project));
  map[loc method, int count] locPerMethod = countLinesOfCodePerMethod(createM3FromEclipseProject(project));
 
  legendaTop =text("Architectural information about <project>", fontSize(15), fontColor("blue"));
  
  Figures classBoxes = [];
  Figures legendaBoxes = [];
  
  spaces = space(size(10,10)); // to create spaces between different objects 
  //Legenda text on the right
  row3 =[ box(size(10,10),resizable(false),fillColor("green")), box(text("NO RISK"))];
  row4 =[ box(size(10,10),resizable(false),fillColor("yellow")), box(text("MODERATE RISK"))];
  row5 =[ box(size(10,10),resizable(false),fillColor("orange")), box(text("HIGH RISK"))];
  row6 =[ box(size(10,10),resizable(false),fillColor("red")), box(text("VERY HIGH RISK"))]; 
  row1= [ellipse(size(10,10),resizable(false),fillColor("black")),
  		box(text("Constructor"))];
  row2 =[box(size(10,10),resizable(false),fillColor("black")),
  		box(text("Method"))];
 
  legendaBoxes += grid([row1, row2, row3, row4, row5, row6], std(fontSize(10)), std(gap(5)), std(lineWidth(0)), std(left()));
  
 list[loc] allClasses = toList(classes(myModel));  

 for(class <- allClasses) {
   list[loc] methoden = ( [ e | e <- myModel@containment[class], e.scheme == "java+method" || e.scheme == "java+constructor"]);


   classBoxes += (box(vcat([
   				    // methods or constructor, build it
   				    checkIn(methods, ccPerMethod[methods], locPerMethod[methods], project)| methods <- methoden ]),     	
  	 			  extraInfoClass(class, size(methoden)),
  	 			  size(10,10),
  	 			  lineWidth(5), 
  	 			  resizable(false),
  	 			  onMouseDownAction(class),
  	 			  fillColor("antiquewhite"),
  	 			  lineColor("black"))
  	 			  );				  	
  }
  legendaSide = hvcat(legendaBoxes, hshrink(0.2));  // legenda
  output = pack(classBoxes, gap(8), std(gap(5)), std(left())); // main visualization of classes and methods.
 
 leftVert = hcat([output, legendaSide]);
 totalView = vcat([legendaTop, leftVert], std(gap(10)), std(left()), std(top()));
 return render("Visualization of packages", totalView);

}

public Figure checkIn(loc methods, int cc, int locs,  loc project) {
    if(contains(toString(methods),"|java+constructor:///")) {
	return	ellipse(size(10, 10+locs),
 						fillColor(color(controlCC(cc))),
				  		onMouseDownAction(methods),
				  		resizable(false),
			 		    extraInfo(methods, locs ,cc)
			 		    );
    }
    if(contains(toString(methods),"|java+method:///")) {
	return	box(size(10, 10+locs),
 						fillColor(color(controlCC(cc))),
				  		onMouseDownAction(methods),
				  		resizable(false),
			 		    extraInfo(methods, locs ,cc)
			 		    );
    }
}
 
 // to make box click-able
 public FProperty onMouseDownAction(loc method){
 	return onMouseDown(bool (int butnr, map[KeyModifier,bool] modifiers) {
		edit(resolveJava(method)); 
		return true;
	});
 }
					 
 public FProperty extraInfoClass(loc nameClass,int amountOfMethods){
         return mouseOver(box(text("Class: <extractName(nameClass)>\n" + 
         						   "Methods: <amountOfMethods>",
         						   font("Osaka")),size(0,0), grow(1.1), right(),bottom(),
         						   fillColor("whitesmoke"),resizable(true)));
}

public FProperty emptyClassInfo(loc nameClass){
         return mouseOver(box(text("Class: <extractName(nameClass)>",
         						   font("Osaka")),size(10,10), grow(1.1), bottom(),
         						   fillColor("whitesmoke"),resizable(false)));
}

 public FProperty extraInfo(loc nameMethod,int methodLOC, int cc){
         return mouseOver(box(text("Method: <extractName(nameMethod)>\n" + 
         						   "LOC: <methodLOC>\n" + 
         						   "Cyclomatic complexity: <cc>",
         						   font("Osaka")),size(0,0), grow(1.1), right(), bottom(),
         						   fillColor("whitesmoke"),resizable(true)));

}
 
// Color the box, depending on cyclomaticComplexity results 
public str controlCC(int cc){
        if( cc <= 25 ) return "Green";
        else if( cc <= 30 ) return "Yellow";
        else if( cc <= 40 ) return "Orange";
        else return "Red";
}

public str extractName(loc location) {
	str unextractedName =toString(location);
	str extracted;
	if (startsWith(unextractedName, "|java+method:///")){
	extracted = replaceFirst(unextractedName, "|java+method:///", "|");
	}
	else if (startsWith(unextractedName, "|java+constructor:///")){
	extracted = replaceFirst(unextractedName, "|java+constructor:///", "|");
	}
	else if (startsWith(unextractedName, "|java+class:///")){
	extracted = replaceFirst(unextractedName, "|java+class:///", "|");
	}
    return extracted;
}
 
