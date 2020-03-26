#!/usr/bin/env python3

import sys
import spacy 
nlp = spacy.load('en_core_web_lg') 
input=sys.argv[1]

entities = dict([(str(x), x.label_) for x in nlp(input).ents if x.label_ == 'PERSON']) 
print(entities)