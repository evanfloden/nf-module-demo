#Nextflow Modules and Components Proposal
 
The reuse and recombination of common tasks has been seen by some as a 
major obstacle to the uptake of Nextflow.


Due to the implicit parallelisation of task execution in NF, defining the 
level at which the modularity should occur has been challenging and confusing 
for the average user. 
 

Whilst individual tasks can be modularised through templates and external scripts, 
having a Nextflow pipeline executed within another Nextflow pipeline is problematic.

 
And whilst NF users often have highly customised tasks they wish to develop, 
many users have common tasks which are often repeated across pipelines 
as well as being interchangeable with tools performing a common function.

 
One solution to this could could be to allow the definition of Nextflow *modules* 
which encapsulate the definitions of similar tools, referred to from here on in 
as *components*. 

 
Each module would be made of components which could share data input/output types. 
However individual components would contain their own specific commands and 
execution environments (containers).

 
To illustrate this with an example, consider the module: 'mapping short reads' 
that contains three mappers/components: kallisto, sailfish and salmon.
 
To be eligible as a component in a module it should should :

* take a **common** input data type (eg. short reads + an index)

* return a **common** output (eg. mapped reads)

* be describable with a **common** tool ontology (eg. short read mapper)

* have a **specific** execution script (eg. template script)

* have a **specific** and self-contained execution environment (eg. container)

 
Using only current NF syntax, we can illustrate how this can work in the demo contained within 
this repository.

 
 
 
 
 

