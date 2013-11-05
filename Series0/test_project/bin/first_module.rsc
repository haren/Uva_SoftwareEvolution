module first_module

import IO;
import List;

//text = ["andra", "moi", "ennepe", "Mousa", "polutropon"];

public list[str] find2(list[str] text){
  return 
    for(s <- text)
      if(/o/ := s)
        append s;        
}

//text = ["the", "jaws", "that", "bite", "the", "claws", "that", "catch"];
public list[str] duplicates2(list[str] text){
    m = {};
    return 
      for(s <- text)
        if(s in m) {
           append s;
        }
        else
           m += s;
}

public bool isPalindrome(list[str] words){
  return words == reverse(words);
}

