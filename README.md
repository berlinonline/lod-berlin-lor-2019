# Berlin's LOR structure ('Lebensweltlich Orientierte Räume') as Linked Open Data, Version 01.01.2019

The 'Lebensweltlich orientierten Räume', or LOR, is a system that divides the city of Berlin into a hierarchy of continuously smaller geographical units. 
At the top are the 12 Bezirke (burroughs).
The Bezirke are divided into Prognoseräume, which are further divided into Bezirksregionen.
Finally, at the lowest level are the Planungsräume.

This version is from 01.01.2019 and contains the 12 Bezirke, 60 Prognoseräume, 138 Bezirksregionen and 448 Planungsräume.
The LORs are the basis for planning, prognosis and monitoring of demographic and social developments in Berlin. 

This dataset is a conversion of the existing WFS-services to Linked Data, or RDF.

The data is converted using a series of scripts and tools, all orchestrated by the [Makefile](Makefile).

It is then published as Linked Open Data using the [LOD Site Generator](https://github.com/berlinonline/lod-sg) repository as a template.

**[Start browsing the data!](https://berlinonline.github.io/lod-berlin-lor-2019/)**

## License

All code in this repository is published under the [MIT License](License). All data (in particular [void.ttl](void.ttl) and [data/target/lors.ttl](data/target/lors.ttl)) are published under [CC0](https://creativecommons.org/publicdomain/zero/1.0/).