#!/usr/local/bin/perl
#VF_class.pl
#This script counts the number of records a dataset has based upon gi accession numbers.  It then does a crude breakdown of the
# file based on the fasta description, counting the number of records which mathc one of the different virulence classes.
#NB. This script is very crude and is only meant to give a quick count of data and not a thorough analysis!
#Author: Raju Misra; October 2006

use warnings;
#use strict;

#intialises the count, for counting the number of hits
my $count_Acaryochloris = 0;
my $count_Acetivibrio = 0;
my $count_Acidiphilium = 0;
my $count_Acidobacteria = 0;
my $count_Acidothermus = 0;
my $count_Acidovorax = 0;
my $count_Acinetobacter = 0;
my $count_Acorus = 0;
my $count_Actinobacillus = 0;
my $count_Actinomyces = 0;
my $count_Acyrthosiphon = 0;
my $count_Aedes = 0;
my $count_Aeromonas = 0;
my $count_Aethionema = 0;
my $count_Agathis = 0;
my $count_Agrobacterium = 0;
my $count_Ajellomyces = 0;
my $count_Alcanivorax = 0;
my $count_Algoriphagus = 0;
my $count_Alicyclobacillus = 0;
my $count_Alkalilimnicola = 0;
my $count_Alkaliphilus = 0;
my $count_Alteromonadales = 0;
my $count_Alteromonas = 0;
my $count_Amaranthus = 0;
my $count_Amborella = 0;
my $count_Ambystoma = 0;
my $count_Amycolatopsis = 0;
my $count_Anabaena = 0;
my $count_Anaeromyxobacter = 0;
my $count_Ananas = 0;
my $count_Anaplasma = 0;
my $count_Angiopteris = 0;
my $count_Anopheles = 0;
my $count_Anoxybacillus = 0;
my $count_Anser = 0;
my $count_Aotus = 0;
my $count_Aphelia = 0;
my $count_Aphyllanthes = 0;
my $count_Apis = 0;
my $count_Aquifex = 0;
my $count_Arabidopsis = 0;
my $count_Arabis = 0;
my $count_Archaeopotamobius = 0;
my $count_Arcobacter = 0;
my $count_Arthrobacter = 0;
my $count_Ascarina = 0;
my $count_Ashbya = 0;
my $count_Aspergillus = 0;
my $count_Asphodelus = 0;
my $count_Aster = 0;
my $count_Asterina = 0;
my $count_Atropa = 0;
my $count_Aurantimonas = 0;
my $count_Austrobaileya = 0;
my $count_Azoarcus = 0;
my $count_Azorhizobium = 0;
my $count_Azospirillum = 0;
my $count_Azotobacter = 0;
my $count_Babesia = 0;
my $count_Bacteriophage = 0;
my $count_Bacteroides = 0;
my $count_Balaenoptera = 0;
my $count_Barbarea = 0;
my $count_Bartonella = 0;
my $count_Baumannia = 0;
my $count_Bdellovibrio = 0;
my $count_Beggiatoa = 0;
my $count_Bifidobacterium = 0;
my $count_Bigelowiella = 0;
my $count_Bilophila = 0;
my $count_Bisgaard = 0;
my $count_Blandfordia = 0;
my $count_Blastopirellula = 0;
my $count_Bombyx = 0;
my $count_Bordetella = 0;
my $count_Borrelia = 0;
my $count_Bos = 0;
my $count_Botryotinia = 0;
my $count_Bradyrhizobium = 0;
my $count_Brevibacterium = 0;
my $count_Brochothrix = 0;
my $count_Brucella = 0;
my $count_Brugia = 0;
my $count_Bubalus = 0;
my $count_Buchnera = 0;
my $count_Burkholderia = 0;
my $count_Burmannia = 0;
my $count_Buxus = 0;
my $count_Cabomba = 0;
my $count_Caenorhabditis = 0;
my $count_Caldibacillus = 0;
my $count_Caldicellulosiruptor = 0;
my $count_Callorhinchus = 0;
my $count_Calochortus = 0;
my $count_Calycanthus = 0;
my $count_Caminibacter = 0;
my $count_Campylobacter = 0;
my $count_Candida = 0;
my $count_candidate = 0;
my $count_Candidatus = 0;
my $count_Canis = 0;
my $count_Capsella = 0;
my $count_Carboxydothermus = 0;
my $count_Cardinium = 0;
my $count_Cartonema = 0;
my $count_Caulobacter = 0;
my $count_Cavia = 0;
my $count_Cellulophaga = 0;
my $count_Cenarchaeum = 0;
my $count_Centrolepis = 0;
my $count_Cephaloscyllium = 0;
my $count_Ceratium = 0;
my $count_Ceratophyllum = 0;
my $count_Ceratotherium = 0;
my $count_Cercidiphyllum = 0;
my $count_Cerebratulus = 0;
my $count_Chaetomium = 0;
my $count_Chaetopterus = 0;
my $count_Chaetosphaeridium = 0;
my $count_Chara = 0;
my $count_Chlamydia = 0;
my $count_Chlamydomonas = 0;
my $count_Chlamydophila = 0;
my $count_Chloranthus = 0;
my $count_Chlorobium = 0;
my $count_Chloroflexus = 0;
my $count_Chlorokybus = 0;
my $count_Chondromyces = 0;
my $count_Chromobacterium = 0;
my $count_Chromohalobacter = 0;
my $count_Citrobacter = 0;
my $count_Citrus = 0;
my $count_Clavibacter = 0;
my $count_Cloning = 0;
my $count_Clostridium = 0;
my $count_Coccidioides = 0;
my $count_Coelogyne = 0;
my $count_Coffea = 0;
my $count_Collinsella = 0;
my $count_Colwellia = 0;
my $count_Comamonas = 0;
my $count_Convolvulus = 0;
my $count_Coprinopsis = 0;
my $count_Coprococcus = 0;
my $count_Corynebacterium = 0;
my $count_Coxiella = 0;
my $count_Crepidula = 0;
my $count_Croceibacter = 0;
my $count_Crocosphaera = 0;
my $count_Crucihimalaya = 0;
my $count_Cryptococcus = 0;
my $count_Cryptosporidium = 0;
my $count_Cucumis = 0;
my $count_Cuscuta = 0;
my $count_Cyanastrum = 0;
my $count_Cyanidioschyzon = 0;
my $count_Cyanidium = 0;
my $count_Cyanothece = 0;
my $count_Cycas = 0;
my $count_Cylindrococcus = 0;
my $count_Cyperus = 0;
my $count_Cypripedium = 0;
my $count_Cytophaga = 0;
my $count_Daegunia = 0;
my $count_Danio = 0;
my $count_Daphniphyllum = 0;
my $count_Dasypogon = 0;
my $count_Daucus = 0;
my $count_Debaryomyces = 0;
my $count_Dechloromonas = 0;
my $count_Dehalococcoides = 0;
my $count_Deinococcus = 0;
my $count_Delftia = 0;
my $count_delta = 0;
my $count_Desulfitobacterium = 0;
my $count_Desulfotalea = 0;
my $count_Desulfotomaculum = 0;
my $count_Desulfovibrio = 0;
my $count_Desulfuromonas = 0;
my $count_Desulfuromusa = 0;
my $count_Dialister = 0;
my $count_Diceros = 0;
my $count_Dichelobacter = 0;
my $count_Dictyostelium = 0;
my $count_Dicyema = 0;
my $count_Didelphis = 0;
my $count_Dinoroseobacter = 0;
my $count_Dioscorea = 0;
my $count_Dorea = 0;
my $count_Draba = 0;
my $count_Drosophila = 0;
my $count_Ehrlichia = 0;
my $count_Elegia = 0;
my $count_Emericella = 0;
my $count_Encephalartos = 0;
my $count_Endoriftia = 0;
my $count_Ensete = 0;
my $count_Entamoeba = 0;
my $count_Enterobacter = 0;
my $count_Enterobacteriaceae = 0;
my $count_Enterococcus = 0;
my $count_Entomoplasma = 0;
my $count_Ephydatia = 0;
my $count_Equus = 0;
my $count_Erwinia = 0;
my $count_Erycibe = 0;
my $count_Erythrobacter = 0;
my $count_Escherichia = 0;
my $count_Eubacterium = 0;
my $count_Eucalyptus = 0;
my $count_Exiguobacterium = 0;
my $count_Faecalibacterium = 0;
my $count_Falkia = 0;
my $count_Fe = 0;
my $count_Felis = 0;
my $count_Ferroplasma = 0;
my $count_Fervidobacterium = 0;
my $count_Flagellaria = 0;
my $count_Flavobacteria = 0;
my $count_Flavobacteriales = 0;
my $count_Flavobacterium = 0;
my $count_Fragaria = 0;
my $count_Francisella = 0;
my $count_Frankia = 0;
my $count_Fulvimarina = 0;
my $count_Fusobacterium = 0;
my $count_Gallus = 0;
my $count_gamma = 0;
my $count_GenusX = 0;
my $count_Geobacillus = 0;
my $count_Geobacter = 0;
my $count_Giardia = 0;
my $count_Gibberella = 0;
my $count_Ginkgo = 0;
my $count_Gloeobacter = 0;
my $count_Gluconacetobacter = 0;
my $count_Gluconobacter = 0;
my $count_Glycine = 0;
my $count_Gossypium = 0;
my $count_Gramella = 0;
my $count_Granulibacter = 0;
my $count_Granulicatella = 0;
my $count_Gunnera = 0;
my $count_Haemophilus = 0;
my $count_Hahella = 0;
my $count_Haliotis = 0;
my $count_Halobacillus = 0;
my $count_Haloquadratum = 0;
my $count_Halorhodospira = 0;
my $count_Halothermothrix = 0;
my $count_Hamamelis = 0;
my $count_Helianthus = 0;
my $count_Helicobacter = 0;
my $count_Helicoverpa = 0;
my $count_Heliobacillus = 0;
my $count_Helmholtzia = 0;
my $count_Hemerocallis = 0;
my $count_Herminiimonas = 0;
my $count_Herpetosiphon = 0;
my $count_Heuchera = 0;
my $count_Hippopotamus = 0;
my $count_Homo = 0;
my $count_Humbertia = 0;
my $count_Huperzia = 0;
my $count_Hydrogenobaculum = 0;
my $count_Hydrothrix = 0;
my $count_Hyphomicrobium = 0;
my $count_Hyphomonas = 0;
my $count_Idiomarina = 0;
my $count_Illicium = 0;
my $count_Ilyobacter = 0;
my $count_Includes = 0;
my $count_includes = 0;
my $count_Ipomoea = 0;
my $count_Iris = 0;
my $count_Iseia = 0;
my $count_isomerizing = 0;
my $count_Jacquemontia = 0;
my $count_Janibacter = 0;
my $count_Jannaschia = 0;
my $count_Janthinobacterium = 0;
my $count_Japonolirion = 0;
my $count_Jasminum = 0;
my $count_Kalanchoe = 0;
my $count_Kineococcus = 0;
my $count_Klebsiella = 0;
my $count_Kluyvera = 0;
my $count_Kluyveromyces = 0;
my $count_Kocuria = 0;
my $count_Kurthia = 0;
my $count_Laceyella = 0;
my $count_Lachnodius = 0;
my $count_Lactobacillus = 0;
my $count_Lactococcus = 0;
my $count_Lactoris = 0;
my $count_Lactuca = 0;
my $count_Larus = 0;
my $count_Lawsonia = 0;
my $count_Legionella = 0;
my $count_Leifsonia = 0;
my $count_Leishmania = 0;
my $count_Lentisphaera = 0;
my $count_Lepidium = 0;
my $count_Lepidosiren = 0;
my $count_Lepidozamia = 0;
my $count_Lepisosteus = 0;
my $count_Lepistemon = 0;
my $count_Leptosira = 0;
my $count_Leptospira = 0;
my $count_Leptospirillum = 0;
my $count_Lepus = 0;
my $count_Lestes = 0;
my $count_Lethenteron = 0;
my $count_Leuconostoc = 0;
my $count_Leucosolenia = 0;
my $count_Lilium = 0;
my $count_Limnobacter = 0;
my $count_Lineus = 0;
my $count_Liriodendron = 0;
my $count_Listeria = 0;
my $count_Lobularia = 0;
my $count_Lodderomyces = 0;
my $count_Loktanella = 0;
my $count_Lomandra = 0;
my $count_Lotus = 0;
my $count_Loxodonta = 0;
my $count_Lyngbya = 0;
my $count_Maburea = 0;
my $count_Macaca = 0;
my $count_Maconellicoccus = 0;
my $count_Macrozamia = 0;
my $count_Magnaporthe = 0;
my $count_Magnetococcus = 0;
my $count_Magnetospirillum = 0;
my $count_Malassezia = 0;
my $count_Mannheimia = 0;
my $count_Maricaulis = 0;
my $count_marine = 0;
my $count_Marinibacillus = 0;
my $count_Marinobacter = 0;
my $count_Marinomonas = 0;
my $count_Maripa = 0;
my $count_Mariprofundus = 0;
my $count_Medeola = 0;
my $count_Medicago = 0;
my $count_Meiothermus = 0;
my $count_Meleagris = 0;
my $count_Merremia = 0;
my $count_Mesocricetus = 0;
my $count_Mesoplasma = 0;
my $count_Mesorhizobium = 0;
my $count_Mesostigma = 0;
my $count_Methanobrevibacter = 0;
my $count_Methanocaldococcus = 0;
my $count_Methanococcus = 0;
my $count_Methanocorpusculum = 0;
my $count_Methanoculleus = 0;
my $count_Methanopyrus = 0;
my $count_Methanosaeta = 0;
my $count_Methanosarcina = 0;
my $count_Methanothermobacter = 0;
my $count_Methylibium = 0;
my $count_Methylobacillus = 0;
my $count_Methylobacterium = 0;
my $count_Methylocapsa = 0;
my $count_Methylococcus = 0;
my $count_Methylophilales = 0;
my $count_Metridium = 0;
my $count_Microbacterium = 0;
my $count_Microciona = 0;
my $count_Microcystis = 0;
my $count_Microscilla = 0;
my $count_Modiolus = 0;
my $count_Monodelphis = 0;
my $count_Monosiga = 0;
my $count_Montinia = 0;
my $count_Moorella = 0;
my $count_Morganella = 0;
my $count_Moritella = 0;
my $count_Morus = 0;
my $count_Muilla = 0;
my $count_Mus = 0;
my $count_Musa = 0;
my $count_Mycobacterium = 0;
my $count_Mycoplasma = 0;
my $count_Myriophyllum = 0;
my $count_Mytilus = 0;
my $count_Myxococcus = 0;
my $count_NADP = 0;
my $count_Nandina = 0;
my $count_Narcissus = 0;
my $count_Narthecium = 0;
my $count_Nasonia = 0;
my $count_Nasturtium = 0;
my $count_Natronomonas = 0;
my $count_Neisseria = 0;
my $count_Nematostella = 0;
my $count_Neorickettsia = 0;
my $count_Neosartorya = 0;
my $count_Neurospora = 0;
my $count_Nicotiana = 0;
my $count_Nitratiruptor = 0;
my $count_Nitrobacter = 0;
my $count_Nitrococcus = 0;
my $count_Nitrosococcus = 0;
my $count_Nitrosomonas = 0;
my $count_Nitrosospira = 0;
my $count_Nocardia = 0;
my $count_Nocardioides = 0;
my $count_Nodularia = 0;
my $count_Nonomuraea = 0;
my $count_Nostoc = 0;
my $count_Notophthalmus = 0;
my $count_Novosphingobium = 0;
my $count_Nucula = 0;
my $count_Nuphar = 0;
my $count_Nymphaea = 0;
my $count_Obelia = 0;
my $count_Oceanicaulis = 0;
my $count_Oceanicola = 0;
my $count_Oceanobacillus = 0;
my $count_Oceanobacter = 0;
my $count_Oceanospirillum = 0;
my $count_Ochrobactrum = 0;
my $count_Odonellia = 0;
my $count_Odontella = 0;
my $count_Oenococcus = 0;
my $count_Olimarabidopsis = 0;
my $count_Olliffia = 0;
my $count_Onion = 0;
my $count_Opisthoscelis = 0;
my $count_Opitutaceae = 0;
my $count_Orientia = 0;
my $count_Orientobilharzia = 0;
my $count_Ornithorhynchus = 0;
my $count_Oryctolagus = 0;
my $count_Oryza = 0;
my $count_Oryzias = 0;
my $count_Ostreococcus = 0;
my $count_Paenibacillus = 0;
my $count_Paeonia = 0;
my $count_Pagrus = 0;
my $count_Pan = 0;
my $count_Panax = 0;
my $count_Papio = 0;
my $count_Parabacteroides = 0;
my $count_Paracoccus = 0;
my $count_Paramecium = 0;
my $count_Parvibaculum = 0;
my $count_Parvularcula = 0;
my $count_Pasteurella = 0;
my $count_Pasteurellaceae = 0;
my $count_Pasteuria = 0;
my $count_Peanut = 0;
my $count_Pediococcus = 0;
my $count_Pedobacter = 0;
my $count_Pelobacter = 0;
my $count_Pelodictyon = 0;
my $count_Pelotomaculum = 0;
my $count_Penicillium = 0;
my $count_Penthorum = 0;
my $count_Peptococcus = 0;
my $count_Peptostreptococcus = 0;
my $count_Peridiscus = 0;
my $count_Petermannia = 0;
my $count_Petrotoga = 0;
my $count_Phaeodactylum = 0;
my $count_Phaeosphaeria = 0;
my $count_Phalaenopsis = 0;
my $count_Phaseolus = 0;
my $count_Phasianus = 0;
my $count_Philydrum = 0;
my $count_Phormium = 0;
my $count_Photobacterium = 0;
my $count_Photorhabdus = 0;
my $count_Phytophthora = 0;
my $count_Pichia = 0;
my $count_Picrophilus = 0;
my $count_Piper = 0;
my $count_Pisum = 0;
my $count_Planctomyces = 0;
my $count_Plasmodium = 0;
my $count_Platanus = 0;
my $count_Plesiocystis = 0;
my $count_Podocarpus = 0;
my $count_Poecilia = 0;
my $count_Polaribacter = 0;
my $count_Polaromonas = 0;
my $count_Polynucleobacter = 0;
my $count_Polypterus = 0;
my $count_Polytomella = 0;
my $count_Pongo = 0;
my $count_Populus = 0;
my $count_Porphyra = 0;
my $count_Porphyromonas = 0;
my $count_Priapulus = 0;
my $count_Prochlorococcus = 0;
my $count_Propionibacterium = 0;
my $count_Prosartes = 0;
my $count_Prosthecochloris = 0;
my $count_Proteus = 0;
my $count_Protopterus = 0;
my $count_Prunus = 0;
my $count_Pseudoalteromonas = 0;
my $count_Pseudococcidae = 0;
my $count_Pseudomonas = 0;
my $count_Psychrobacter = 0;
my $count_Psychroflexus = 0;
my $count_Psychromonas = 0;
my $count_Pterostemon = 0;
my $count_Pyrococcus = 0;
my $count_Ralstonia = 0;
my $count_Rana = 0;
my $count_Ranunculus = 0;
my $count_Raoultella = 0;
my $count_Rapona = 0;
my $count_Rattus = 0;
my $count_Reinekea = 0;
my $count_Rheum = 0;
my $count_Rhizobium = 0;
my $count_Rhodobacter = 0;
my $count_Rhodobacterales = 0;
my $count_Rhodococcus = 0;
my $count_Rhodoferax = 0;
my $count_Rhodomonas = 0;
my $count_Rhodopirellula = 0;
my $count_Rhodopseudomonas = 0;
my $count_Rhodospirillum = 0;
my $count_Ribes = 0;
my $count_Rickettsia = 0;
my $count_Rickettsiella = 0;
my $count_Robiginitalea = 0;
my $count_Roseiflexus = 0;
my $count_Roseobacter = 0;
my $count_Roseovarius = 0;
my $count_Rubrobacter = 0;
my $count_Ruminococcus = 0;
my $count_Saccharomyces = 0;
my $count_Saccharophagus = 0;
my $count_Saccharopolyspora = 0;
my $count_Saccoglossus = 0;
my $count_Sagittula = 0;
my $count_Salinibacter = 0;
my $count_Salinispora = 0;
my $count_Salinivibrio = 0;
my $count_Salmonella = 0;
my $count_Sarcophaga = 0;
my $count_Saururus = 0;
my $count_Saxegothaea = 0;
my $count_Saxifraga = 0;
my $count_Scheuchzeria = 0;
my $count_Schisandra = 0;
my $count_Schistosoma = 0;
my $count_Schizanthus = 0;
my $count_Sciadopitys = 0;
my $count_Sclerotinia = 0;
my $count_Scyliorhinus = 0;
my $count_Serratia = 0;
my $count_Shewanella = 0;
my $count_Shigella = 0;
my $count_Silicibacter = 0;
my $count_similarity = 0;
my $count_Sinorhizobium = 0;
my $count_Smilacina = 0;
my $count_Smilax = 0;
my $count_Sminthopsis = 0;
my $count_Sodalis = 0;
my $count_Solanum = 0;
my $count_Solibacter = 0;
my $count_Spathiphyllum = 0;
my $count_Sphaerococcopsis = 0;
my $count_Sphingomonas = 0;
my $count_Sphingopyxis = 0;
my $count_Spinacia = 0;
my $count_Spiroplasma = 0;
my $count_Sporosarcina = 0;
my $count_Staphylococcus = 0;
my $count_Stappia = 0;
my $count_Stemona = 0;
my $count_Stenotrophomonas = 0;
my $count_Stigeoclonium = 0;
my $count_Stigmatella = 0;
my $count_Streptobacillus = 0;
my $count_Streptococcus = 0;
my $count_Streptomyces = 0;
my $count_Strongylocentrotus = 0;
my $count_Stylochus = 0;
my $count_Sulfitobacter = 0;
my $count_Sulfurovum = 0;
my $count_Sus = 0;
my $count_swine = 0;
my $count_Sycon = 0;
my $count_Symbiobacterium = 0;
my $count_Synechococcus = 0;
my $count_Synechocystis = 0;
my $count_synthetic = 0;
my $count_Syntrophobacter = 0;
my $count_Syntrophomonas = 0;
my $count_Syntrophus = 0;
my $count_Tadarida = 0;
my $count_Talbotia = 0;
my $count_Tenacibaculum = 0;
my $count_Tenebrio = 0;
my $count_Tetragenococcus = 0;
my $count_Tetrahymena = 0;
my $count_Tetraodon = 0;
my $count_Thalassiosira = 0;
my $count_Theileria = 0;
my $count_Thermoactinomyces = 0;
my $count_Thermoanaerobacter = 0;
my $count_Thermobifida = 0;
my $count_Thermococcus = 0;
my $count_Thermoflavimicrobium = 0;
my $count_Thermoplasma = 0;
my $count_Thermosinus = 0;
my $count_Thermosipho = 0;
my $count_Thermosynechococcus = 0;
my $count_Thermotoga = 0;
my $count_Thermus = 0;
my $count_Thiobacillus = 0;
my $count_Thiomicrospira = 0;
my $count_Tissierella = 0;
my $count_Tofieldia = 0;
my $count_Treponema = 0;
my $count_Tribolium = 0;
my $count_Trichodesmium = 0;
my $count_Trichomonas = 0;
my $count_Tricyrtis = 0;
my $count_Trillium = 0;
my $count_Trithuria = 0;
my $count_Trochodendron = 0;
my $count_Trochospongilla = 0;
my $count_Tropheryma = 0;
my $count_Trypanosoma = 0;
my $count_Tupaia = 0;
my $count_Typha = 0;
my $count_uncultured = 0;
my $count_unidentified = 0;
my $count_Ureaplasma = 0;
my $count_Ustilago = 0;
my $count_Vagococcus = 0;
my $count_Vanderwaltozyma = 0;
my $count_Veillonella = 0;
my $count_Verminephrobacter = 0;
my $count_Vibrio = 0;
my $count_Vibrionales = 0;
my $count_Victivallis = 0;
my $count_Virgibacillus = 0;
my $count_Vitis = 0;
my $count_Weissella = 0;
my $count_Wigglesworthia = 0;
my $count_Wolbachia = 0;
my $count_Wolinella = 0;
my $count_Xanthobacter = 0;
my $count_Xanthomonas = 0;
my $count_Xanthorrhoea = 0;
my $count_Xenopus = 0;
my $count_Xeronema = 0;
my $count_Xiphidium = 0;
my $count_Xiphophorus = 0;
my $count_Xylella = 0;
my $count_Xyris = 0;
my $count_Yarrowia = 0;
my $count_Yersinia = 0;
my $count_Yucca = 0;
my $count_Zymomonas = 0;


#Prompt the user for the name of the file to read.
print "Enter the filename and then press Enter:\n";
my $fileToRead = <STDIN>;
chomp($fileToRead);
open (INFILE, $fileToRead) or die( "Cannot open file : $!" );

#opns the output file
open(OUTFILE, ">file_length.txt");
while (my $sequenceEntry = <INFILE>) {

#the magic: goes through the output file, if the word to be searched for is found it
#counts it.
if ($sequenceEntry =~ m/Acaryochloris/i) {$count_Acaryochloris++}
if ($sequenceEntry =~ m/Acetivibrio/i) {$count_Acetivibrio++}
if ($sequenceEntry =~ m/Acidiphilium/i) {$count_Acidiphilium++}
if ($sequenceEntry =~ m/Acidobacteria/i) {$count_Acidobacteria++}
if ($sequenceEntry =~ m/Acidothermus/i) {$count_Acidothermus++}
if ($sequenceEntry =~ m/Acidovorax/i) {$count_Acidovorax++}
if ($sequenceEntry =~ m/Acinetobacter/i) {$count_Acinetobacter++}
if ($sequenceEntry =~ m/Acorus/i) {$count_Acorus++}
if ($sequenceEntry =~ m/Actinobacillus/i) {$count_Actinobacillus++}
if ($sequenceEntry =~ m/Actinomyces/i) {$count_Actinomyces++}
if ($sequenceEntry =~ m/Acyrthosiphon/i) {$count_Acyrthosiphon++}
if ($sequenceEntry =~ m/Aedes/i) {$count_Aedes++}
if ($sequenceEntry =~ m/Aeromonas/i) {$count_Aeromonas++}
if ($sequenceEntry =~ m/Aethionema/i) {$count_Aethionema++}
if ($sequenceEntry =~ m/Agathis/i) {$count_Agathis++}
if ($sequenceEntry =~ m/Agrobacterium/i) {$count_Agrobacterium++}
if ($sequenceEntry =~ m/Ajellomyces/i) {$count_Ajellomyces++}
if ($sequenceEntry =~ m/Alcanivorax/i) {$count_Alcanivorax++}
if ($sequenceEntry =~ m/Algoriphagus/i) {$count_Algoriphagus++}
if ($sequenceEntry =~ m/Alicyclobacillus/i) {$count_Alicyclobacillus++}
if ($sequenceEntry =~ m/Alkalilimnicola/i) {$count_Alkalilimnicola++}
if ($sequenceEntry =~ m/Alkaliphilus/i) {$count_Alkaliphilus++}
if ($sequenceEntry =~ m/Alteromonadales/i) {$count_Alteromonadales++}
if ($sequenceEntry =~ m/Alteromonas/i) {$count_Alteromonas++}
if ($sequenceEntry =~ m/Amaranthus/i) {$count_Amaranthus++}
if ($sequenceEntry =~ m/Amborella/i) {$count_Amborella++}
if ($sequenceEntry =~ m/Ambystoma/i) {$count_Ambystoma++}
if ($sequenceEntry =~ m/Amycolatopsis/i) {$count_Amycolatopsis++}
if ($sequenceEntry =~ m/Anabaena/i) {$count_Anabaena++}
if ($sequenceEntry =~ m/Anaeromyxobacter/i) {$count_Anaeromyxobacter++}
if ($sequenceEntry =~ m/Ananas/i) {$count_Ananas++}
if ($sequenceEntry =~ m/Anaplasma/i) {$count_Anaplasma++}
if ($sequenceEntry =~ m/Angiopteris/i) {$count_Angiopteris++}
if ($sequenceEntry =~ m/Anopheles/i) {$count_Anopheles++}
if ($sequenceEntry =~ m/Anoxybacillus/i) {$count_Anoxybacillus++}
if ($sequenceEntry =~ m/Anser/i) {$count_Anser++}
if ($sequenceEntry =~ m/Aotus/i) {$count_Aotus++}
if ($sequenceEntry =~ m/Aphelia/i) {$count_Aphelia++}
if ($sequenceEntry =~ m/Aphyllanthes/i) {$count_Aphyllanthes++}
if ($sequenceEntry =~ m/Apis/i) {$count_Apis++}
if ($sequenceEntry =~ m/Aquifex/i) {$count_Aquifex++}
if ($sequenceEntry =~ m/Arabidopsis/i) {$count_Arabidopsis++}
if ($sequenceEntry =~ m/Arabis/i) {$count_Arabis++}
if ($sequenceEntry =~ m/Archaeopotamobius/i) {$count_Archaeopotamobius++}
if ($sequenceEntry =~ m/Arcobacter/i) {$count_Arcobacter++}
if ($sequenceEntry =~ m/Arthrobacter/i) {$count_Arthrobacter++}
if ($sequenceEntry =~ m/Ascarina/i) {$count_Ascarina++}
if ($sequenceEntry =~ m/Ashbya/i) {$count_Ashbya++}
if ($sequenceEntry =~ m/Aspergillus/i) {$count_Aspergillus++}
if ($sequenceEntry =~ m/Asphodelus/i) {$count_Asphodelus++}
if ($sequenceEntry =~ m/Aster/i) {$count_Aster++}
if ($sequenceEntry =~ m/Asterina/i) {$count_Asterina++}
if ($sequenceEntry =~ m/Atropa/i) {$count_Atropa++}
if ($sequenceEntry =~ m/Aurantimonas/i) {$count_Aurantimonas++}
if ($sequenceEntry =~ m/Austrobaileya/i) {$count_Austrobaileya++}
if ($sequenceEntry =~ m/Azoarcus/i) {$count_Azoarcus++}
if ($sequenceEntry =~ m/Azorhizobium/i) {$count_Azorhizobium++}
if ($sequenceEntry =~ m/Azospirillum/i) {$count_Azospirillum++}
if ($sequenceEntry =~ m/Azotobacter/i) {$count_Azotobacter++}
if ($sequenceEntry =~ m/Babesia/i) {$count_Babesia++}
if ($sequenceEntry =~ m/Bacteriophage/i) {$count_Bacteriophage++}
if ($sequenceEntry =~ m/Bacteroides/i) {$count_Bacteroides++}
if ($sequenceEntry =~ m/Balaenoptera/i) {$count_Balaenoptera++}
if ($sequenceEntry =~ m/Barbarea/i) {$count_Barbarea++}
if ($sequenceEntry =~ m/Bartonella/i) {$count_Bartonella++}
if ($sequenceEntry =~ m/Baumannia/i) {$count_Baumannia++}
if ($sequenceEntry =~ m/Bdellovibrio/i) {$count_Bdellovibrio++}
if ($sequenceEntry =~ m/Beggiatoa/i) {$count_Beggiatoa++}
if ($sequenceEntry =~ m/Bifidobacterium/i) {$count_Bifidobacterium++}
if ($sequenceEntry =~ m/Bigelowiella/i) {$count_Bigelowiella++}
if ($sequenceEntry =~ m/Bilophila/i) {$count_Bilophila++}
if ($sequenceEntry =~ m/Bisgaard/i) {$count_Bisgaard++}
if ($sequenceEntry =~ m/Blandfordia/i) {$count_Blandfordia++}
if ($sequenceEntry =~ m/Blastopirellula/i) {$count_Blastopirellula++}
if ($sequenceEntry =~ m/Bombyx/i) {$count_Bombyx++}
if ($sequenceEntry =~ m/Bordetella/i) {$count_Bordetella++}
if ($sequenceEntry =~ m/Borrelia/i) {$count_Borrelia++}
if ($sequenceEntry =~ m/Bos/i) {$count_Bos++}
if ($sequenceEntry =~ m/Botryotinia/i) {$count_Botryotinia++}
if ($sequenceEntry =~ m/Bradyrhizobium/i) {$count_Bradyrhizobium++}
if ($sequenceEntry =~ m/Brevibacterium/i) {$count_Brevibacterium++}
if ($sequenceEntry =~ m/Brochothrix/i) {$count_Brochothrix++}
if ($sequenceEntry =~ m/Brucella/i) {$count_Brucella++}
if ($sequenceEntry =~ m/Brugia/i) {$count_Brugia++}
if ($sequenceEntry =~ m/Bubalus/i) {$count_Bubalus++}
if ($sequenceEntry =~ m/Buchnera/i) {$count_Buchnera++}
if ($sequenceEntry =~ m/Burkholderia/i) {$count_Burkholderia++}
if ($sequenceEntry =~ m/Burmannia/i) {$count_Burmannia++}
if ($sequenceEntry =~ m/Buxus/i) {$count_Buxus++}
if ($sequenceEntry =~ m/Cabomba/i) {$count_Cabomba++}
if ($sequenceEntry =~ m/Caenorhabditis/i) {$count_Caenorhabditis++}
if ($sequenceEntry =~ m/Caldibacillus/i) {$count_Caldibacillus++}
if ($sequenceEntry =~ m/Caldicellulosiruptor/i) {$count_Caldicellulosiruptor++}
if ($sequenceEntry =~ m/Callorhinchus/i) {$count_Callorhinchus++}
if ($sequenceEntry =~ m/Calochortus/i) {$count_Calochortus++}
if ($sequenceEntry =~ m/Calycanthus/i) {$count_Calycanthus++}
if ($sequenceEntry =~ m/Caminibacter/i) {$count_Caminibacter++}
if ($sequenceEntry =~ m/Campylobacter/i) {$count_Campylobacter++}
if ($sequenceEntry =~ m/Candida/i) {$count_Candida++}
if ($sequenceEntry =~ m/candidate/i) {$count_candidate++}
if ($sequenceEntry =~ m/Candidatus/i) {$count_Candidatus++}
if ($sequenceEntry =~ m/Canis/i) {$count_Canis++}
if ($sequenceEntry =~ m/Capsella/i) {$count_Capsella++}
if ($sequenceEntry =~ m/Carboxydothermus/i) {$count_Carboxydothermus++}
if ($sequenceEntry =~ m/Cardinium/i) {$count_Cardinium++}
if ($sequenceEntry =~ m/Cartonema/i) {$count_Cartonema++}
if ($sequenceEntry =~ m/Caulobacter/i) {$count_Caulobacter++}
if ($sequenceEntry =~ m/Cavia/i) {$count_Cavia++}
if ($sequenceEntry =~ m/Cellulophaga/i) {$count_Cellulophaga++}
if ($sequenceEntry =~ m/Cenarchaeum/i) {$count_Cenarchaeum++}
if ($sequenceEntry =~ m/Centrolepis/i) {$count_Centrolepis++}
if ($sequenceEntry =~ m/Cephaloscyllium/i) {$count_Cephaloscyllium++}
if ($sequenceEntry =~ m/Ceratium/i) {$count_Ceratium++}
if ($sequenceEntry =~ m/Ceratophyllum/i) {$count_Ceratophyllum++}
if ($sequenceEntry =~ m/Ceratotherium/i) {$count_Ceratotherium++}
if ($sequenceEntry =~ m/Cercidiphyllum/i) {$count_Cercidiphyllum++}
if ($sequenceEntry =~ m/Cerebratulus/i) {$count_Cerebratulus++}
if ($sequenceEntry =~ m/Chaetomium/i) {$count_Chaetomium++}
if ($sequenceEntry =~ m/Chaetopterus/i) {$count_Chaetopterus++}
if ($sequenceEntry =~ m/Chaetosphaeridium/i) {$count_Chaetosphaeridium++}
if ($sequenceEntry =~ m/Chara/i) {$count_Chara++}
if ($sequenceEntry =~ m/Chlamydia/i) {$count_Chlamydia++}
if ($sequenceEntry =~ m/Chlamydomonas/i) {$count_Chlamydomonas++}
if ($sequenceEntry =~ m/Chlamydophila/i) {$count_Chlamydophila++}
if ($sequenceEntry =~ m/Chloranthus/i) {$count_Chloranthus++}
if ($sequenceEntry =~ m/Chlorobium/i) {$count_Chlorobium++}
if ($sequenceEntry =~ m/Chloroflexus/i) {$count_Chloroflexus++}
if ($sequenceEntry =~ m/Chlorokybus/i) {$count_Chlorokybus++}
if ($sequenceEntry =~ m/Chondromyces/i) {$count_Chondromyces++}
if ($sequenceEntry =~ m/Chromobacterium/i) {$count_Chromobacterium++}
if ($sequenceEntry =~ m/Chromohalobacter/i) {$count_Chromohalobacter++}
if ($sequenceEntry =~ m/Citrobacter/i) {$count_Citrobacter++}
if ($sequenceEntry =~ m/Citrus/i) {$count_Citrus++}
if ($sequenceEntry =~ m/Clavibacter/i) {$count_Clavibacter++}
if ($sequenceEntry =~ m/Cloning/i) {$count_Cloning++}
if ($sequenceEntry =~ m/Clostridium/i) {$count_Clostridium++}
if ($sequenceEntry =~ m/Coccidioides/i) {$count_Coccidioides++}
if ($sequenceEntry =~ m/Coelogyne/i) {$count_Coelogyne++}
if ($sequenceEntry =~ m/Coffea/i) {$count_Coffea++}
if ($sequenceEntry =~ m/Collinsella/i) {$count_Collinsella++}
if ($sequenceEntry =~ m/Colwellia/i) {$count_Colwellia++}
if ($sequenceEntry =~ m/Comamonas/i) {$count_Comamonas++}
if ($sequenceEntry =~ m/Convolvulus/i) {$count_Convolvulus++}
if ($sequenceEntry =~ m/Coprinopsis/i) {$count_Coprinopsis++}
if ($sequenceEntry =~ m/Coprococcus/i) {$count_Coprococcus++}
if ($sequenceEntry =~ m/Corynebacterium/i) {$count_Corynebacterium++}
if ($sequenceEntry =~ m/Coxiella/i) {$count_Coxiella++}
if ($sequenceEntry =~ m/Crepidula/i) {$count_Crepidula++}
if ($sequenceEntry =~ m/Croceibacter/i) {$count_Croceibacter++}
if ($sequenceEntry =~ m/Crocosphaera/i) {$count_Crocosphaera++}
if ($sequenceEntry =~ m/Crucihimalaya/i) {$count_Crucihimalaya++}
if ($sequenceEntry =~ m/Cryptococcus/i) {$count_Cryptococcus++}
if ($sequenceEntry =~ m/Cryptosporidium/i) {$count_Cryptosporidium++}
if ($sequenceEntry =~ m/Cucumis/i) {$count_Cucumis++}
if ($sequenceEntry =~ m/Cuscuta/i) {$count_Cuscuta++}
if ($sequenceEntry =~ m/Cyanastrum/i) {$count_Cyanastrum++}
if ($sequenceEntry =~ m/Cyanidioschyzon/i) {$count_Cyanidioschyzon++}
if ($sequenceEntry =~ m/Cyanidium/i) {$count_Cyanidium++}
if ($sequenceEntry =~ m/Cyanothece/i) {$count_Cyanothece++}
if ($sequenceEntry =~ m/Cycas/i) {$count_Cycas++}
if ($sequenceEntry =~ m/Cylindrococcus/i) {$count_Cylindrococcus++}
if ($sequenceEntry =~ m/Cyperus/i) {$count_Cyperus++}
if ($sequenceEntry =~ m/Cypripedium/i) {$count_Cypripedium++}
if ($sequenceEntry =~ m/Cytophaga/i) {$count_Cytophaga++}
if ($sequenceEntry =~ m/Daegunia/i) {$count_Daegunia++}
if ($sequenceEntry =~ m/Danio/i) {$count_Danio++}
if ($sequenceEntry =~ m/Daphniphyllum/i) {$count_Daphniphyllum++}
if ($sequenceEntry =~ m/Dasypogon/i) {$count_Dasypogon++}
if ($sequenceEntry =~ m/Daucus/i) {$count_Daucus++}
if ($sequenceEntry =~ m/Debaryomyces/i) {$count_Debaryomyces++}
if ($sequenceEntry =~ m/Dechloromonas/i) {$count_Dechloromonas++}
if ($sequenceEntry =~ m/Dehalococcoides/i) {$count_Dehalococcoides++}
if ($sequenceEntry =~ m/Deinococcus/i) {$count_Deinococcus++}
if ($sequenceEntry =~ m/Delftia/i) {$count_Delftia++}
if ($sequenceEntry =~ m/delta/i) {$count_delta++}
if ($sequenceEntry =~ m/Desulfitobacterium/i) {$count_Desulfitobacterium++}
if ($sequenceEntry =~ m/Desulfotalea/i) {$count_Desulfotalea++}
if ($sequenceEntry =~ m/Desulfotomaculum/i) {$count_Desulfotomaculum++}
if ($sequenceEntry =~ m/Desulfovibrio/i) {$count_Desulfovibrio++}
if ($sequenceEntry =~ m/Desulfuromonas/i) {$count_Desulfuromonas++}
if ($sequenceEntry =~ m/Desulfuromusa/i) {$count_Desulfuromusa++}
if ($sequenceEntry =~ m/Dialister/i) {$count_Dialister++}
if ($sequenceEntry =~ m/Diceros/i) {$count_Diceros++}
if ($sequenceEntry =~ m/Dichelobacter/i) {$count_Dichelobacter++}
if ($sequenceEntry =~ m/Dictyostelium/i) {$count_Dictyostelium++}
if ($sequenceEntry =~ m/Dicyema/i) {$count_Dicyema++}
if ($sequenceEntry =~ m/Didelphis/i) {$count_Didelphis++}
if ($sequenceEntry =~ m/Dinoroseobacter/i) {$count_Dinoroseobacter++}
if ($sequenceEntry =~ m/Dioscorea/i) {$count_Dioscorea++}
if ($sequenceEntry =~ m/Dorea/i) {$count_Dorea++}
if ($sequenceEntry =~ m/Draba/i) {$count_Draba++}
if ($sequenceEntry =~ m/Drosophila/i) {$count_Drosophila++}
if ($sequenceEntry =~ m/Ehrlichia/i) {$count_Ehrlichia++}
if ($sequenceEntry =~ m/Elegia/i) {$count_Elegia++}
if ($sequenceEntry =~ m/Emericella/i) {$count_Emericella++}
if ($sequenceEntry =~ m/Encephalartos/i) {$count_Encephalartos++}
if ($sequenceEntry =~ m/Endoriftia/i) {$count_Endoriftia++}
if ($sequenceEntry =~ m/Ensete/i) {$count_Ensete++}
if ($sequenceEntry =~ m/Entamoeba/i) {$count_Entamoeba++}
if ($sequenceEntry =~ m/Enterobacter/i) {$count_Enterobacter++}
if ($sequenceEntry =~ m/Enterobacteriaceae/i) {$count_Enterobacteriaceae++}
if ($sequenceEntry =~ m/Enterococcus/i) {$count_Enterococcus++}
if ($sequenceEntry =~ m/Entomoplasma/i) {$count_Entomoplasma++}
if ($sequenceEntry =~ m/Ephydatia/i) {$count_Ephydatia++}
if ($sequenceEntry =~ m/Equus/i) {$count_Equus++}
if ($sequenceEntry =~ m/Erwinia/i) {$count_Erwinia++}
if ($sequenceEntry =~ m/Erycibe/i) {$count_Erycibe++}
if ($sequenceEntry =~ m/Erythrobacter/i) {$count_Erythrobacter++}
if ($sequenceEntry =~ m/Escherichia/i) {$count_Escherichia++}
if ($sequenceEntry =~ m/Eubacterium/i) {$count_Eubacterium++}
if ($sequenceEntry =~ m/Eucalyptus/i) {$count_Eucalyptus++}
if ($sequenceEntry =~ m/Exiguobacterium/i) {$count_Exiguobacterium++}
if ($sequenceEntry =~ m/Faecalibacterium/i) {$count_Faecalibacterium++}
if ($sequenceEntry =~ m/Falkia/i) {$count_Falkia++}
if ($sequenceEntry =~ m/Fe/i) {$count_Fe++}
if ($sequenceEntry =~ m/Felis/i) {$count_Felis++}
if ($sequenceEntry =~ m/Ferroplasma/i) {$count_Ferroplasma++}
if ($sequenceEntry =~ m/Fervidobacterium/i) {$count_Fervidobacterium++}
if ($sequenceEntry =~ m/Flagellaria/i) {$count_Flagellaria++}
if ($sequenceEntry =~ m/Flavobacteria/i) {$count_Flavobacteria++}
if ($sequenceEntry =~ m/Flavobacteriales/i) {$count_Flavobacteriales++}
if ($sequenceEntry =~ m/Flavobacterium/i) {$count_Flavobacterium++}
if ($sequenceEntry =~ m/Fragaria/i) {$count_Fragaria++}
if ($sequenceEntry =~ m/Francisella/i) {$count_Francisella++}
if ($sequenceEntry =~ m/Frankia/i) {$count_Frankia++}
if ($sequenceEntry =~ m/Fulvimarina/i) {$count_Fulvimarina++}
if ($sequenceEntry =~ m/Fusobacterium/i) {$count_Fusobacterium++}
if ($sequenceEntry =~ m/Gallus/i) {$count_Gallus++}
if ($sequenceEntry =~ m/gamma/i) {$count_gamma++}
if ($sequenceEntry =~ m/GenusX/i) {$count_GenusX++}
if ($sequenceEntry =~ m/Geobacillus/i) {$count_Geobacillus++}
if ($sequenceEntry =~ m/Geobacter/i) {$count_Geobacter++}
if ($sequenceEntry =~ m/Giardia/i) {$count_Giardia++}
if ($sequenceEntry =~ m/Gibberella/i) {$count_Gibberella++}
if ($sequenceEntry =~ m/Ginkgo/i) {$count_Ginkgo++}
if ($sequenceEntry =~ m/Gloeobacter/i) {$count_Gloeobacter++}
if ($sequenceEntry =~ m/Gluconacetobacter/i) {$count_Gluconacetobacter++}
if ($sequenceEntry =~ m/Gluconobacter/i) {$count_Gluconobacter++}
if ($sequenceEntry =~ m/Glycine/i) {$count_Glycine++}
if ($sequenceEntry =~ m/Gossypium/i) {$count_Gossypium++}
if ($sequenceEntry =~ m/Gramella/i) {$count_Gramella++}
if ($sequenceEntry =~ m/Granulibacter/i) {$count_Granulibacter++}
if ($sequenceEntry =~ m/Granulicatella/i) {$count_Granulicatella++}
if ($sequenceEntry =~ m/Gunnera/i) {$count_Gunnera++}
if ($sequenceEntry =~ m/Haemophilus/i) {$count_Haemophilus++}
if ($sequenceEntry =~ m/Hahella/i) {$count_Hahella++}
if ($sequenceEntry =~ m/Haliotis/i) {$count_Haliotis++}
if ($sequenceEntry =~ m/Halobacillus/i) {$count_Halobacillus++}
if ($sequenceEntry =~ m/Haloquadratum/i) {$count_Haloquadratum++}
if ($sequenceEntry =~ m/Halorhodospira/i) {$count_Halorhodospira++}
if ($sequenceEntry =~ m/Halothermothrix/i) {$count_Halothermothrix++}
if ($sequenceEntry =~ m/Hamamelis/i) {$count_Hamamelis++}
if ($sequenceEntry =~ m/Helianthus/i) {$count_Helianthus++}
if ($sequenceEntry =~ m/Helicobacter/i) {$count_Helicobacter++}
if ($sequenceEntry =~ m/Helicoverpa/i) {$count_Helicoverpa++}
if ($sequenceEntry =~ m/Heliobacillus/i) {$count_Heliobacillus++}
if ($sequenceEntry =~ m/Helmholtzia/i) {$count_Helmholtzia++}
if ($sequenceEntry =~ m/Hemerocallis/i) {$count_Hemerocallis++}
if ($sequenceEntry =~ m/Herminiimonas/i) {$count_Herminiimonas++}
if ($sequenceEntry =~ m/Herpetosiphon/i) {$count_Herpetosiphon++}
if ($sequenceEntry =~ m/Heuchera/i) {$count_Heuchera++}
if ($sequenceEntry =~ m/Hippopotamus/i) {$count_Hippopotamus++}
if ($sequenceEntry =~ m/Homo/i) {$count_Homo++}
if ($sequenceEntry =~ m/Humbertia/i) {$count_Humbertia++}
if ($sequenceEntry =~ m/Huperzia/i) {$count_Huperzia++}
if ($sequenceEntry =~ m/Hydrogenobaculum/i) {$count_Hydrogenobaculum++}
if ($sequenceEntry =~ m/Hydrothrix/i) {$count_Hydrothrix++}
if ($sequenceEntry =~ m/Hyphomicrobium/i) {$count_Hyphomicrobium++}
if ($sequenceEntry =~ m/Hyphomonas/i) {$count_Hyphomonas++}
if ($sequenceEntry =~ m/Idiomarina/i) {$count_Idiomarina++}
if ($sequenceEntry =~ m/Illicium/i) {$count_Illicium++}
if ($sequenceEntry =~ m/Ilyobacter/i) {$count_Ilyobacter++}
if ($sequenceEntry =~ m/Includes/i) {$count_Includes++}
if ($sequenceEntry =~ m/includes/i) {$count_includes++}
if ($sequenceEntry =~ m/Ipomoea/i) {$count_Ipomoea++}
if ($sequenceEntry =~ m/Iris/i) {$count_Iris++}
if ($sequenceEntry =~ m/Iseia/i) {$count_Iseia++}
if ($sequenceEntry =~ m/isomerizing/i) {$count_isomerizing++}
if ($sequenceEntry =~ m/Jacquemontia/i) {$count_Jacquemontia++}
if ($sequenceEntry =~ m/Janibacter/i) {$count_Janibacter++}
if ($sequenceEntry =~ m/Jannaschia/i) {$count_Jannaschia++}
if ($sequenceEntry =~ m/Janthinobacterium/i) {$count_Janthinobacterium++}
if ($sequenceEntry =~ m/Japonolirion/i) {$count_Japonolirion++}
if ($sequenceEntry =~ m/Jasminum/i) {$count_Jasminum++}
if ($sequenceEntry =~ m/Kalanchoe/i) {$count_Kalanchoe++}
if ($sequenceEntry =~ m/Kineococcus/i) {$count_Kineococcus++}
if ($sequenceEntry =~ m/Klebsiella/i) {$count_Klebsiella++}
if ($sequenceEntry =~ m/Kluyvera/i) {$count_Kluyvera++}
if ($sequenceEntry =~ m/Kluyveromyces/i) {$count_Kluyveromyces++}
if ($sequenceEntry =~ m/Kocuria/i) {$count_Kocuria++}
if ($sequenceEntry =~ m/Kurthia/i) {$count_Kurthia++}
if ($sequenceEntry =~ m/Laceyella/i) {$count_Laceyella++}
if ($sequenceEntry =~ m/Lachnodius/i) {$count_Lachnodius++}
if ($sequenceEntry =~ m/Lactobacillus/i) {$count_Lactobacillus++}
if ($sequenceEntry =~ m/Lactococcus/i) {$count_Lactococcus++}
if ($sequenceEntry =~ m/Lactoris/i) {$count_Lactoris++}
if ($sequenceEntry =~ m/Lactuca/i) {$count_Lactuca++}
if ($sequenceEntry =~ m/Larus/i) {$count_Larus++}
if ($sequenceEntry =~ m/Lawsonia/i) {$count_Lawsonia++}
if ($sequenceEntry =~ m/Legionella/i) {$count_Legionella++}
if ($sequenceEntry =~ m/Leifsonia/i) {$count_Leifsonia++}
if ($sequenceEntry =~ m/Leishmania/i) {$count_Leishmania++}
if ($sequenceEntry =~ m/Lentisphaera/i) {$count_Lentisphaera++}
if ($sequenceEntry =~ m/Lepidium/i) {$count_Lepidium++}
if ($sequenceEntry =~ m/Lepidosiren/i) {$count_Lepidosiren++}
if ($sequenceEntry =~ m/Lepidozamia/i) {$count_Lepidozamia++}
if ($sequenceEntry =~ m/Lepisosteus/i) {$count_Lepisosteus++}
if ($sequenceEntry =~ m/Lepistemon/i) {$count_Lepistemon++}
if ($sequenceEntry =~ m/Leptosira/i) {$count_Leptosira++}
if ($sequenceEntry =~ m/Leptospira/i) {$count_Leptospira++}
if ($sequenceEntry =~ m/Leptospirillum/i) {$count_Leptospirillum++}
if ($sequenceEntry =~ m/Lepus/i) {$count_Lepus++}
if ($sequenceEntry =~ m/Lestes/i) {$count_Lestes++}
if ($sequenceEntry =~ m/Lethenteron/i) {$count_Lethenteron++}
if ($sequenceEntry =~ m/Leuconostoc/i) {$count_Leuconostoc++}
if ($sequenceEntry =~ m/Leucosolenia/i) {$count_Leucosolenia++}
if ($sequenceEntry =~ m/Lilium/i) {$count_Lilium++}
if ($sequenceEntry =~ m/Limnobacter/i) {$count_Limnobacter++}
if ($sequenceEntry =~ m/Lineus/i) {$count_Lineus++}
if ($sequenceEntry =~ m/Liriodendron/i) {$count_Liriodendron++}
if ($sequenceEntry =~ m/Listeria/i) {$count_Listeria++}
if ($sequenceEntry =~ m/Lobularia/i) {$count_Lobularia++}
if ($sequenceEntry =~ m/Lodderomyces/i) {$count_Lodderomyces++}
if ($sequenceEntry =~ m/Loktanella/i) {$count_Loktanella++}
if ($sequenceEntry =~ m/Lomandra/i) {$count_Lomandra++}
if ($sequenceEntry =~ m/Lotus/i) {$count_Lotus++}
if ($sequenceEntry =~ m/Loxodonta/i) {$count_Loxodonta++}
if ($sequenceEntry =~ m/Lyngbya/i) {$count_Lyngbya++}
if ($sequenceEntry =~ m/Maburea/i) {$count_Maburea++}
if ($sequenceEntry =~ m/Macaca/i) {$count_Macaca++}
if ($sequenceEntry =~ m/Maconellicoccus/i) {$count_Maconellicoccus++}
if ($sequenceEntry =~ m/Macrozamia/i) {$count_Macrozamia++}
if ($sequenceEntry =~ m/Magnaporthe/i) {$count_Magnaporthe++}
if ($sequenceEntry =~ m/Magnetococcus/i) {$count_Magnetococcus++}
if ($sequenceEntry =~ m/Magnetospirillum/i) {$count_Magnetospirillum++}
if ($sequenceEntry =~ m/Malassezia/i) {$count_Malassezia++}
if ($sequenceEntry =~ m/Mannheimia/i) {$count_Mannheimia++}
if ($sequenceEntry =~ m/Maricaulis/i) {$count_Maricaulis++}
if ($sequenceEntry =~ m/marine/i) {$count_marine++}
if ($sequenceEntry =~ m/Marinibacillus/i) {$count_Marinibacillus++}
if ($sequenceEntry =~ m/Marinobacter/i) {$count_Marinobacter++}
if ($sequenceEntry =~ m/Marinomonas/i) {$count_Marinomonas++}
if ($sequenceEntry =~ m/Maripa/i) {$count_Maripa++}
if ($sequenceEntry =~ m/Mariprofundus/i) {$count_Mariprofundus++}
if ($sequenceEntry =~ m/Medeola/i) {$count_Medeola++}
if ($sequenceEntry =~ m/Medicago/i) {$count_Medicago++}
if ($sequenceEntry =~ m/Meiothermus/i) {$count_Meiothermus++}
if ($sequenceEntry =~ m/Meleagris/i) {$count_Meleagris++}
if ($sequenceEntry =~ m/Merremia/i) {$count_Merremia++}
if ($sequenceEntry =~ m/Mesocricetus/i) {$count_Mesocricetus++}
if ($sequenceEntry =~ m/Mesoplasma/i) {$count_Mesoplasma++}
if ($sequenceEntry =~ m/Mesorhizobium/i) {$count_Mesorhizobium++}
if ($sequenceEntry =~ m/Mesostigma/i) {$count_Mesostigma++}
if ($sequenceEntry =~ m/Methanobrevibacter/i) {$count_Methanobrevibacter++}
if ($sequenceEntry =~ m/Methanocaldococcus/i) {$count_Methanocaldococcus++}
if ($sequenceEntry =~ m/Methanococcus/i) {$count_Methanococcus++}
if ($sequenceEntry =~ m/Methanocorpusculum/i) {$count_Methanocorpusculum++}
if ($sequenceEntry =~ m/Methanoculleus/i) {$count_Methanoculleus++}
if ($sequenceEntry =~ m/Methanopyrus/i) {$count_Methanopyrus++}
if ($sequenceEntry =~ m/Methanosaeta/i) {$count_Methanosaeta++}
if ($sequenceEntry =~ m/Methanosarcina/i) {$count_Methanosarcina++}
if ($sequenceEntry =~ m/Methanothermobacter/i) {$count_Methanothermobacter++}
if ($sequenceEntry =~ m/Methylibium/i) {$count_Methylibium++}
if ($sequenceEntry =~ m/Methylobacillus/i) {$count_Methylobacillus++}
if ($sequenceEntry =~ m/Methylobacterium/i) {$count_Methylobacterium++}
if ($sequenceEntry =~ m/Methylocapsa/i) {$count_Methylocapsa++}
if ($sequenceEntry =~ m/Methylococcus/i) {$count_Methylococcus++}
if ($sequenceEntry =~ m/Methylophilales/i) {$count_Methylophilales++}
if ($sequenceEntry =~ m/Metridium/i) {$count_Metridium++}
if ($sequenceEntry =~ m/Microbacterium/i) {$count_Microbacterium++}
if ($sequenceEntry =~ m/Microciona/i) {$count_Microciona++}
if ($sequenceEntry =~ m/Microcystis/i) {$count_Microcystis++}
if ($sequenceEntry =~ m/Microscilla/i) {$count_Microscilla++}
if ($sequenceEntry =~ m/Modiolus/i) {$count_Modiolus++}
if ($sequenceEntry =~ m/Monodelphis/i) {$count_Monodelphis++}
if ($sequenceEntry =~ m/Monosiga/i) {$count_Monosiga++}
if ($sequenceEntry =~ m/Montinia/i) {$count_Montinia++}
if ($sequenceEntry =~ m/Moorella/i) {$count_Moorella++}
if ($sequenceEntry =~ m/Morganella/i) {$count_Morganella++}
if ($sequenceEntry =~ m/Moritella/i) {$count_Moritella++}
if ($sequenceEntry =~ m/Morus/i) {$count_Morus++}
if ($sequenceEntry =~ m/Muilla/i) {$count_Muilla++}
if ($sequenceEntry =~ m/Mus/i) {$count_Mus++}
if ($sequenceEntry =~ m/Musa/i) {$count_Musa++}
if ($sequenceEntry =~ m/Mycobacterium/i) {$count_Mycobacterium++}
if ($sequenceEntry =~ m/Mycoplasma/i) {$count_Mycoplasma++}
if ($sequenceEntry =~ m/Myriophyllum/i) {$count_Myriophyllum++}
if ($sequenceEntry =~ m/Mytilus/i) {$count_Mytilus++}
if ($sequenceEntry =~ m/Myxococcus/i) {$count_Myxococcus++}
if ($sequenceEntry =~ m/NADP/i) {$count_NADP++}
if ($sequenceEntry =~ m/Nandina/i) {$count_Nandina++}
if ($sequenceEntry =~ m/Narcissus/i) {$count_Narcissus++}
if ($sequenceEntry =~ m/Narthecium/i) {$count_Narthecium++}
if ($sequenceEntry =~ m/Nasonia/i) {$count_Nasonia++}
if ($sequenceEntry =~ m/Nasturtium/i) {$count_Nasturtium++}
if ($sequenceEntry =~ m/Natronomonas/i) {$count_Natronomonas++}
if ($sequenceEntry =~ m/Neisseria/i) {$count_Neisseria++}
if ($sequenceEntry =~ m/Nematostella/i) {$count_Nematostella++}
if ($sequenceEntry =~ m/Neorickettsia/i) {$count_Neorickettsia++}
if ($sequenceEntry =~ m/Neosartorya/i) {$count_Neosartorya++}
if ($sequenceEntry =~ m/Neurospora/i) {$count_Neurospora++}
if ($sequenceEntry =~ m/Nicotiana/i) {$count_Nicotiana++}
if ($sequenceEntry =~ m/Nitratiruptor/i) {$count_Nitratiruptor++}
if ($sequenceEntry =~ m/Nitrobacter/i) {$count_Nitrobacter++}
if ($sequenceEntry =~ m/Nitrococcus/i) {$count_Nitrococcus++}
if ($sequenceEntry =~ m/Nitrosococcus/i) {$count_Nitrosococcus++}
if ($sequenceEntry =~ m/Nitrosomonas/i) {$count_Nitrosomonas++}
if ($sequenceEntry =~ m/Nitrosospira/i) {$count_Nitrosospira++}
if ($sequenceEntry =~ m/Nocardia/i) {$count_Nocardia++}
if ($sequenceEntry =~ m/Nocardioides/i) {$count_Nocardioides++}
if ($sequenceEntry =~ m/Nodularia/i) {$count_Nodularia++}
if ($sequenceEntry =~ m/Nonomuraea/i) {$count_Nonomuraea++}
if ($sequenceEntry =~ m/Nostoc/i) {$count_Nostoc++}
if ($sequenceEntry =~ m/Notophthalmus/i) {$count_Notophthalmus++}
if ($sequenceEntry =~ m/Novosphingobium/i) {$count_Novosphingobium++}
if ($sequenceEntry =~ m/Nucula/i) {$count_Nucula++}
if ($sequenceEntry =~ m/Nuphar/i) {$count_Nuphar++}
if ($sequenceEntry =~ m/Nymphaea/i) {$count_Nymphaea++}
if ($sequenceEntry =~ m/Obelia/i) {$count_Obelia++}
if ($sequenceEntry =~ m/Oceanicaulis/i) {$count_Oceanicaulis++}
if ($sequenceEntry =~ m/Oceanicola/i) {$count_Oceanicola++}
if ($sequenceEntry =~ m/Oceanobacillus/i) {$count_Oceanobacillus++}
if ($sequenceEntry =~ m/Oceanobacter/i) {$count_Oceanobacter++}
if ($sequenceEntry =~ m/Oceanospirillum/i) {$count_Oceanospirillum++}
if ($sequenceEntry =~ m/Ochrobactrum/i) {$count_Ochrobactrum++}
if ($sequenceEntry =~ m/Odonellia/i) {$count_Odonellia++}
if ($sequenceEntry =~ m/Odontella/i) {$count_Odontella++}
if ($sequenceEntry =~ m/Oenococcus/i) {$count_Oenococcus++}
if ($sequenceEntry =~ m/Olimarabidopsis/i) {$count_Olimarabidopsis++}
if ($sequenceEntry =~ m/Olliffia/i) {$count_Olliffia++}
if ($sequenceEntry =~ m/Onion/i) {$count_Onion++}
if ($sequenceEntry =~ m/Opisthoscelis/i) {$count_Opisthoscelis++}
if ($sequenceEntry =~ m/Opitutaceae/i) {$count_Opitutaceae++}
if ($sequenceEntry =~ m/Orientia/i) {$count_Orientia++}
if ($sequenceEntry =~ m/Orientobilharzia/i) {$count_Orientobilharzia++}
if ($sequenceEntry =~ m/Ornithorhynchus/i) {$count_Ornithorhynchus++}
if ($sequenceEntry =~ m/Oryctolagus/i) {$count_Oryctolagus++}
if ($sequenceEntry =~ m/Oryza/i) {$count_Oryza++}
if ($sequenceEntry =~ m/Oryzias/i) {$count_Oryzias++}
if ($sequenceEntry =~ m/Ostreococcus/i) {$count_Ostreococcus++}
if ($sequenceEntry =~ m/Paenibacillus/i) {$count_Paenibacillus++}
if ($sequenceEntry =~ m/Paeonia/i) {$count_Paeonia++}
if ($sequenceEntry =~ m/Pagrus/i) {$count_Pagrus++}
if ($sequenceEntry =~ m/Pan/i) {$count_Pan++}
if ($sequenceEntry =~ m/Panax/i) {$count_Panax++}
if ($sequenceEntry =~ m/Papio/i) {$count_Papio++}
if ($sequenceEntry =~ m/Parabacteroides/i) {$count_Parabacteroides++}
if ($sequenceEntry =~ m/Paracoccus/i) {$count_Paracoccus++}
if ($sequenceEntry =~ m/Paramecium/i) {$count_Paramecium++}
if ($sequenceEntry =~ m/Parvibaculum/i) {$count_Parvibaculum++}
if ($sequenceEntry =~ m/Parvularcula/i) {$count_Parvularcula++}
if ($sequenceEntry =~ m/Pasteurella/i) {$count_Pasteurella++}
if ($sequenceEntry =~ m/Pasteurellaceae/i) {$count_Pasteurellaceae++}
if ($sequenceEntry =~ m/Pasteuria/i) {$count_Pasteuria++}
if ($sequenceEntry =~ m/Peanut/i) {$count_Peanut++}
if ($sequenceEntry =~ m/Pediococcus/i) {$count_Pediococcus++}
if ($sequenceEntry =~ m/Pedobacter/i) {$count_Pedobacter++}
if ($sequenceEntry =~ m/Pelobacter/i) {$count_Pelobacter++}
if ($sequenceEntry =~ m/Pelodictyon/i) {$count_Pelodictyon++}
if ($sequenceEntry =~ m/Pelotomaculum/i) {$count_Pelotomaculum++}
if ($sequenceEntry =~ m/Penicillium/i) {$count_Penicillium++}
if ($sequenceEntry =~ m/Penthorum/i) {$count_Penthorum++}
if ($sequenceEntry =~ m/Peptococcus/i) {$count_Peptococcus++}
if ($sequenceEntry =~ m/Peptostreptococcus/i) {$count_Peptostreptococcus++}
if ($sequenceEntry =~ m/Peridiscus/i) {$count_Peridiscus++}
if ($sequenceEntry =~ m/Petermannia/i) {$count_Petermannia++}
if ($sequenceEntry =~ m/Petrotoga/i) {$count_Petrotoga++}
if ($sequenceEntry =~ m/Phaeodactylum/i) {$count_Phaeodactylum++}
if ($sequenceEntry =~ m/Phaeosphaeria/i) {$count_Phaeosphaeria++}
if ($sequenceEntry =~ m/Phalaenopsis/i) {$count_Phalaenopsis++}
if ($sequenceEntry =~ m/Phaseolus/i) {$count_Phaseolus++}
if ($sequenceEntry =~ m/Phasianus/i) {$count_Phasianus++}
if ($sequenceEntry =~ m/Philydrum/i) {$count_Philydrum++}
if ($sequenceEntry =~ m/Phormium/i) {$count_Phormium++}
if ($sequenceEntry =~ m/Photobacterium/i) {$count_Photobacterium++}
if ($sequenceEntry =~ m/Photorhabdus/i) {$count_Photorhabdus++}
if ($sequenceEntry =~ m/Phytophthora/i) {$count_Phytophthora++}
if ($sequenceEntry =~ m/Pichia/i) {$count_Pichia++}
if ($sequenceEntry =~ m/Picrophilus/i) {$count_Picrophilus++}
if ($sequenceEntry =~ m/Piper/i) {$count_Piper++}
if ($sequenceEntry =~ m/Pisum/i) {$count_Pisum++}
if ($sequenceEntry =~ m/Planctomyces/i) {$count_Planctomyces++}
if ($sequenceEntry =~ m/Plasmodium/i) {$count_Plasmodium++}
if ($sequenceEntry =~ m/Platanus/i) {$count_Platanus++}
if ($sequenceEntry =~ m/Plesiocystis/i) {$count_Plesiocystis++}
if ($sequenceEntry =~ m/Podocarpus/i) {$count_Podocarpus++}
if ($sequenceEntry =~ m/Poecilia/i) {$count_Poecilia++}
if ($sequenceEntry =~ m/Polaribacter/i) {$count_Polaribacter++}
if ($sequenceEntry =~ m/Polaromonas/i) {$count_Polaromonas++}
if ($sequenceEntry =~ m/Polynucleobacter/i) {$count_Polynucleobacter++}
if ($sequenceEntry =~ m/Polypterus/i) {$count_Polypterus++}
if ($sequenceEntry =~ m/Polytomella/i) {$count_Polytomella++}
if ($sequenceEntry =~ m/Pongo/i) {$count_Pongo++}
if ($sequenceEntry =~ m/Populus/i) {$count_Populus++}
if ($sequenceEntry =~ m/Porphyra/i) {$count_Porphyra++}
if ($sequenceEntry =~ m/Porphyromonas/i) {$count_Porphyromonas++}
if ($sequenceEntry =~ m/Priapulus/i) {$count_Priapulus++}
if ($sequenceEntry =~ m/Prochlorococcus/i) {$count_Prochlorococcus++}
if ($sequenceEntry =~ m/Propionibacterium/i) {$count_Propionibacterium++}
if ($sequenceEntry =~ m/Prosartes/i) {$count_Prosartes++}
if ($sequenceEntry =~ m/Prosthecochloris/i) {$count_Prosthecochloris++}
if ($sequenceEntry =~ m/Proteus/i) {$count_Proteus++}
if ($sequenceEntry =~ m/Protopterus/i) {$count_Protopterus++}
if ($sequenceEntry =~ m/Prunus/i) {$count_Prunus++}
if ($sequenceEntry =~ m/Pseudoalteromonas/i) {$count_Pseudoalteromonas++}
if ($sequenceEntry =~ m/Pseudococcidae/i) {$count_Pseudococcidae++}
if ($sequenceEntry =~ m/Pseudomonas/i) {$count_Pseudomonas++}
if ($sequenceEntry =~ m/Psychrobacter/i) {$count_Psychrobacter++}
if ($sequenceEntry =~ m/Psychroflexus/i) {$count_Psychroflexus++}
if ($sequenceEntry =~ m/Psychromonas/i) {$count_Psychromonas++}
if ($sequenceEntry =~ m/Pterostemon/i) {$count_Pterostemon++}
if ($sequenceEntry =~ m/Pyrococcus/i) {$count_Pyrococcus++}
if ($sequenceEntry =~ m/Ralstonia/i) {$count_Ralstonia++}
if ($sequenceEntry =~ m/Rana/i) {$count_Rana++}
if ($sequenceEntry =~ m/Ranunculus/i) {$count_Ranunculus++}
if ($sequenceEntry =~ m/Raoultella/i) {$count_Raoultella++}
if ($sequenceEntry =~ m/Rapona/i) {$count_Rapona++}
if ($sequenceEntry =~ m/Rattus/i) {$count_Rattus++}
if ($sequenceEntry =~ m/Reinekea/i) {$count_Reinekea++}
if ($sequenceEntry =~ m/Rheum/i) {$count_Rheum++}
if ($sequenceEntry =~ m/Rhizobium/i) {$count_Rhizobium++}
if ($sequenceEntry =~ m/Rhodobacter/i) {$count_Rhodobacter++}
if ($sequenceEntry =~ m/Rhodobacterales/i) {$count_Rhodobacterales++}
if ($sequenceEntry =~ m/Rhodococcus/i) {$count_Rhodococcus++}
if ($sequenceEntry =~ m/Rhodoferax/i) {$count_Rhodoferax++}
if ($sequenceEntry =~ m/Rhodomonas/i) {$count_Rhodomonas++}
if ($sequenceEntry =~ m/Rhodopirellula/i) {$count_Rhodopirellula++}
if ($sequenceEntry =~ m/Rhodopseudomonas/i) {$count_Rhodopseudomonas++}
if ($sequenceEntry =~ m/Rhodospirillum/i) {$count_Rhodospirillum++}
if ($sequenceEntry =~ m/Ribes/i) {$count_Ribes++}
if ($sequenceEntry =~ m/Rickettsia/i) {$count_Rickettsia++}
if ($sequenceEntry =~ m/Rickettsiella/i) {$count_Rickettsiella++}
if ($sequenceEntry =~ m/Robiginitalea/i) {$count_Robiginitalea++}
if ($sequenceEntry =~ m/Roseiflexus/i) {$count_Roseiflexus++}
if ($sequenceEntry =~ m/Roseobacter/i) {$count_Roseobacter++}
if ($sequenceEntry =~ m/Roseovarius/i) {$count_Roseovarius++}
if ($sequenceEntry =~ m/Rubrobacter/i) {$count_Rubrobacter++}
if ($sequenceEntry =~ m/Ruminococcus/i) {$count_Ruminococcus++}
if ($sequenceEntry =~ m/Saccharomyces/i) {$count_Saccharomyces++}
if ($sequenceEntry =~ m/Saccharophagus/i) {$count_Saccharophagus++}
if ($sequenceEntry =~ m/Saccharopolyspora/i) {$count_Saccharopolyspora++}
if ($sequenceEntry =~ m/Saccoglossus/i) {$count_Saccoglossus++}
if ($sequenceEntry =~ m/Sagittula/i) {$count_Sagittula++}
if ($sequenceEntry =~ m/Salinibacter/i) {$count_Salinibacter++}
if ($sequenceEntry =~ m/Salinispora/i) {$count_Salinispora++}
if ($sequenceEntry =~ m/Salinivibrio/i) {$count_Salinivibrio++}
if ($sequenceEntry =~ m/Salmonella/i) {$count_Salmonella++}
if ($sequenceEntry =~ m/Sarcophaga/i) {$count_Sarcophaga++}
if ($sequenceEntry =~ m/Saururus/i) {$count_Saururus++}
if ($sequenceEntry =~ m/Saxegothaea/i) {$count_Saxegothaea++}
if ($sequenceEntry =~ m/Saxifraga/i) {$count_Saxifraga++}
if ($sequenceEntry =~ m/Scheuchzeria/i) {$count_Scheuchzeria++}
if ($sequenceEntry =~ m/Schisandra/i) {$count_Schisandra++}
if ($sequenceEntry =~ m/Schistosoma/i) {$count_Schistosoma++}
if ($sequenceEntry =~ m/Schizanthus/i) {$count_Schizanthus++}
if ($sequenceEntry =~ m/Sciadopitys/i) {$count_Sciadopitys++}
if ($sequenceEntry =~ m/Sclerotinia/i) {$count_Sclerotinia++}
if ($sequenceEntry =~ m/Scyliorhinus/i) {$count_Scyliorhinus++}
if ($sequenceEntry =~ m/Serratia/i) {$count_Serratia++}
if ($sequenceEntry =~ m/Shewanella/i) {$count_Shewanella++}
if ($sequenceEntry =~ m/Shigella/i) {$count_Shigella++}
if ($sequenceEntry =~ m/Silicibacter/i) {$count_Silicibacter++}
if ($sequenceEntry =~ m/similarity/i) {$count_similarity++}
if ($sequenceEntry =~ m/Sinorhizobium/i) {$count_Sinorhizobium++}
if ($sequenceEntry =~ m/Smilacina/i) {$count_Smilacina++}
if ($sequenceEntry =~ m/Smilax/i) {$count_Smilax++}
if ($sequenceEntry =~ m/Sminthopsis/i) {$count_Sminthopsis++}
if ($sequenceEntry =~ m/Sodalis/i) {$count_Sodalis++}
if ($sequenceEntry =~ m/Solanum/i) {$count_Solanum++}
if ($sequenceEntry =~ m/Solibacter/i) {$count_Solibacter++}
if ($sequenceEntry =~ m/Spathiphyllum/i) {$count_Spathiphyllum++}
if ($sequenceEntry =~ m/Sphaerococcopsis/i) {$count_Sphaerococcopsis++}
if ($sequenceEntry =~ m/Sphingomonas/i) {$count_Sphingomonas++}
if ($sequenceEntry =~ m/Sphingopyxis/i) {$count_Sphingopyxis++}
if ($sequenceEntry =~ m/Spinacia/i) {$count_Spinacia++}
if ($sequenceEntry =~ m/Spiroplasma/i) {$count_Spiroplasma++}
if ($sequenceEntry =~ m/Sporosarcina/i) {$count_Sporosarcina++}
if ($sequenceEntry =~ m/Staphylococcus/i) {$count_Staphylococcus++}
if ($sequenceEntry =~ m/Stappia/i) {$count_Stappia++}
if ($sequenceEntry =~ m/Stemona/i) {$count_Stemona++}
if ($sequenceEntry =~ m/Stenotrophomonas/i) {$count_Stenotrophomonas++}
if ($sequenceEntry =~ m/Stigeoclonium/i) {$count_Stigeoclonium++}
if ($sequenceEntry =~ m/Stigmatella/i) {$count_Stigmatella++}
if ($sequenceEntry =~ m/Streptobacillus/i) {$count_Streptobacillus++}
if ($sequenceEntry =~ m/Streptococcus/i) {$count_Streptococcus++}
if ($sequenceEntry =~ m/Streptomyces/i) {$count_Streptomyces++}
if ($sequenceEntry =~ m/Strongylocentrotus/i) {$count_Strongylocentrotus++}
if ($sequenceEntry =~ m/Stylochus/i) {$count_Stylochus++}
if ($sequenceEntry =~ m/Sulfitobacter/i) {$count_Sulfitobacter++}
if ($sequenceEntry =~ m/Sulfurovum/i) {$count_Sulfurovum++}
if ($sequenceEntry =~ m/Sus/i) {$count_Sus++}
if ($sequenceEntry =~ m/swine/i) {$count_swine++}
if ($sequenceEntry =~ m/Sycon/i) {$count_Sycon++}
if ($sequenceEntry =~ m/Symbiobacterium/i) {$count_Symbiobacterium++}
if ($sequenceEntry =~ m/Synechococcus/i) {$count_Synechococcus++}
if ($sequenceEntry =~ m/Synechocystis/i) {$count_Synechocystis++}
if ($sequenceEntry =~ m/synthetic/i) {$count_synthetic++}
if ($sequenceEntry =~ m/Syntrophobacter/i) {$count_Syntrophobacter++}
if ($sequenceEntry =~ m/Syntrophomonas/i) {$count_Syntrophomonas++}
if ($sequenceEntry =~ m/Syntrophus/i) {$count_Syntrophus++}
if ($sequenceEntry =~ m/Tadarida/i) {$count_Tadarida++}
if ($sequenceEntry =~ m/Talbotia/i) {$count_Talbotia++}
if ($sequenceEntry =~ m/Tenacibaculum/i) {$count_Tenacibaculum++}
if ($sequenceEntry =~ m/Tenebrio/i) {$count_Tenebrio++}
if ($sequenceEntry =~ m/Tetragenococcus/i) {$count_Tetragenococcus++}
if ($sequenceEntry =~ m/Tetrahymena/i) {$count_Tetrahymena++}
if ($sequenceEntry =~ m/Tetraodon/i) {$count_Tetraodon++}
if ($sequenceEntry =~ m/Thalassiosira/i) {$count_Thalassiosira++}
if ($sequenceEntry =~ m/Theileria/i) {$count_Theileria++}
if ($sequenceEntry =~ m/Thermoactinomyces/i) {$count_Thermoactinomyces++}
if ($sequenceEntry =~ m/Thermoanaerobacter/i) {$count_Thermoanaerobacter++}
if ($sequenceEntry =~ m/Thermobifida/i) {$count_Thermobifida++}
if ($sequenceEntry =~ m/Thermococcus/i) {$count_Thermococcus++}
if ($sequenceEntry =~ m/Thermoflavimicrobium/i) {$count_Thermoflavimicrobium++}
if ($sequenceEntry =~ m/Thermoplasma/i) {$count_Thermoplasma++}
if ($sequenceEntry =~ m/Thermosinus/i) {$count_Thermosinus++}
if ($sequenceEntry =~ m/Thermosipho/i) {$count_Thermosipho++}
if ($sequenceEntry =~ m/Thermosynechococcus/i) {$count_Thermosynechococcus++}
if ($sequenceEntry =~ m/Thermotoga/i) {$count_Thermotoga++}
if ($sequenceEntry =~ m/Thermus/i) {$count_Thermus++}
if ($sequenceEntry =~ m/Thiobacillus/i) {$count_Thiobacillus++}
if ($sequenceEntry =~ m/Thiomicrospira/i) {$count_Thiomicrospira++}
if ($sequenceEntry =~ m/Tissierella/i) {$count_Tissierella++}
if ($sequenceEntry =~ m/Tofieldia/i) {$count_Tofieldia++}
if ($sequenceEntry =~ m/Treponema/i) {$count_Treponema++}
if ($sequenceEntry =~ m/Tribolium/i) {$count_Tribolium++}
if ($sequenceEntry =~ m/Trichodesmium/i) {$count_Trichodesmium++}
if ($sequenceEntry =~ m/Trichomonas/i) {$count_Trichomonas++}
if ($sequenceEntry =~ m/Tricyrtis/i) {$count_Tricyrtis++}
if ($sequenceEntry =~ m/Trillium/i) {$count_Trillium++}
if ($sequenceEntry =~ m/Trithuria/i) {$count_Trithuria++}
if ($sequenceEntry =~ m/Trochodendron/i) {$count_Trochodendron++}
if ($sequenceEntry =~ m/Trochospongilla/i) {$count_Trochospongilla++}
if ($sequenceEntry =~ m/Tropheryma/i) {$count_Tropheryma++}
if ($sequenceEntry =~ m/Trypanosoma/i) {$count_Trypanosoma++}
if ($sequenceEntry =~ m/Tupaia/i) {$count_Tupaia++}
if ($sequenceEntry =~ m/Typha/i) {$count_Typha++}
if ($sequenceEntry =~ m/uncultured/i) {$count_uncultured++}
if ($sequenceEntry =~ m/unidentified/i) {$count_unidentified++}
if ($sequenceEntry =~ m/Ureaplasma/i) {$count_Ureaplasma++}
if ($sequenceEntry =~ m/Ustilago/i) {$count_Ustilago++}
if ($sequenceEntry =~ m/Vagococcus/i) {$count_Vagococcus++}
if ($sequenceEntry =~ m/Vanderwaltozyma/i) {$count_Vanderwaltozyma++}
if ($sequenceEntry =~ m/Veillonella/i) {$count_Veillonella++}
if ($sequenceEntry =~ m/Verminephrobacter/i) {$count_Verminephrobacter++}
if ($sequenceEntry =~ m/Vibrio/i) {$count_Vibrio++}
if ($sequenceEntry =~ m/Vibrionales/i) {$count_Vibrionales++}
if ($sequenceEntry =~ m/Victivallis/i) {$count_Victivallis++}
if ($sequenceEntry =~ m/Virgibacillus/i) {$count_Virgibacillus++}
if ($sequenceEntry =~ m/Vitis/i) {$count_Vitis++}
if ($sequenceEntry =~ m/Weissella/i) {$count_Weissella++}
if ($sequenceEntry =~ m/Wigglesworthia/i) {$count_Wigglesworthia++}
if ($sequenceEntry =~ m/Wolbachia/i) {$count_Wolbachia++}
if ($sequenceEntry =~ m/Wolinella/i) {$count_Wolinella++}
if ($sequenceEntry =~ m/Xanthobacter/i) {$count_Xanthobacter++}
if ($sequenceEntry =~ m/Xanthomonas/i) {$count_Xanthomonas++}
if ($sequenceEntry =~ m/Xanthorrhoea/i) {$count_Xanthorrhoea++}
if ($sequenceEntry =~ m/Xenopus/i) {$count_Xenopus++}
if ($sequenceEntry =~ m/Xeronema/i) {$count_Xeronema++}
if ($sequenceEntry =~ m/Xiphidium/i) {$count_Xiphidium++}
if ($sequenceEntry =~ m/Xiphophorus/i) {$count_Xiphophorus++}
if ($sequenceEntry =~ m/Xylella/i) {$count_Xylella++}
if ($sequenceEntry =~ m/Xyris/i) {$count_Xyris++}
if ($sequenceEntry =~ m/Yarrowia/i) {$count_Yarrowia++}
if ($sequenceEntry =~ m/Yersinia/i) {$count_Yersinia++}
if ($sequenceEntry =~ m/Yucca/i) {$count_Yucca++}
if ($sequenceEntry =~ m/Zymomonas/i) {$count_Zymomonas++}
if ($sequenceEntry =~ m/Zymomonas/i) {$count_Zymomonas++}

}

close (INFILE) or die( "Cannot close file : $!");

#prints the final word count

print OUTFILE "Total number of *Acaryochloris* is *$count_Acaryochloris*\n";
print OUTFILE "Total number of *Acetivibrio* is *$count_Acetivibrio*\n";
print OUTFILE "Total number of *Acidiphilium* is *$count_Acidiphilium*\n";
print OUTFILE "Total number of *Acidobacteria* is *$count_Acidobacteria*\n";
print OUTFILE "Total number of *Acidothermus* is *$count_Acidothermus*\n";
print OUTFILE "Total number of *Acidovorax* is *$count_Acidovorax*\n";
print OUTFILE "Total number of *Acinetobacter* is *$count_Acinetobacter*\n";
print OUTFILE "Total number of *Acorus* is *$count_Acorus*\n";
print OUTFILE "Total number of *Actinobacillus* is *$count_Actinobacillus*\n";
print OUTFILE "Total number of *Actinomyces* is *$count_Actinomyces*\n";
print OUTFILE "Total number of *Acyrthosiphon* is *$count_Acyrthosiphon*\n";
print OUTFILE "Total number of *Aedes* is *$count_Aedes*\n";
print OUTFILE "Total number of *Aeromonas* is *$count_Aeromonas*\n";
print OUTFILE "Total number of *Aethionema* is *$count_Aethionema*\n";
print OUTFILE "Total number of *Agathis* is *$count_Agathis*\n";
print OUTFILE "Total number of *Agrobacterium* is *$count_Agrobacterium*\n";
print OUTFILE "Total number of *Ajellomyces* is *$count_Ajellomyces*\n";
print OUTFILE "Total number of *Alcanivorax* is *$count_Alcanivorax*\n";
print OUTFILE "Total number of *Algoriphagus* is *$count_Algoriphagus*\n";
print OUTFILE "Total number of *Alicyclobacillus* is *$count_Alicyclobacillus*\n";
print OUTFILE "Total number of *Alkalilimnicola* is *$count_Alkalilimnicola*\n";
print OUTFILE "Total number of *Alkaliphilus* is *$count_Alkaliphilus*\n";
print OUTFILE "Total number of *Alteromonadales* is *$count_Alteromonadales*\n";
print OUTFILE "Total number of *Alteromonas* is *$count_Alteromonas*\n";
print OUTFILE "Total number of *Amaranthus* is *$count_Amaranthus*\n";
print OUTFILE "Total number of *Amborella* is *$count_Amborella*\n";
print OUTFILE "Total number of *Ambystoma* is *$count_Ambystoma*\n";
print OUTFILE "Total number of *Amycolatopsis* is *$count_Amycolatopsis*\n";
print OUTFILE "Total number of *Anabaena* is *$count_Anabaena*\n";
print OUTFILE "Total number of *Anaeromyxobacter* is *$count_Anaeromyxobacter*\n";
print OUTFILE "Total number of *Ananas* is *$count_Ananas*\n";
print OUTFILE "Total number of *Anaplasma* is *$count_Anaplasma*\n";
print OUTFILE "Total number of *Angiopteris* is *$count_Angiopteris*\n";
print OUTFILE "Total number of *Anopheles* is *$count_Anopheles*\n";
print OUTFILE "Total number of *Anoxybacillus* is *$count_Anoxybacillus*\n";
print OUTFILE "Total number of *Anser* is *$count_Anser*\n";
print OUTFILE "Total number of *Aotus* is *$count_Aotus*\n";
print OUTFILE "Total number of *Aphelia* is *$count_Aphelia*\n";
print OUTFILE "Total number of *Aphyllanthes* is *$count_Aphyllanthes*\n";
print OUTFILE "Total number of *Apis* is *$count_Apis*\n";
print OUTFILE "Total number of *Aquifex* is *$count_Aquifex*\n";
print OUTFILE "Total number of *Arabidopsis* is *$count_Arabidopsis*\n";
print OUTFILE "Total number of *Arabis* is *$count_Arabis*\n";
print OUTFILE "Total number of *Archaeopotamobius* is *$count_Archaeopotamobius*\n";
print OUTFILE "Total number of *Arcobacter* is *$count_Arcobacter*\n";
print OUTFILE "Total number of *Arthrobacter* is *$count_Arthrobacter*\n";
print OUTFILE "Total number of *Ascarina* is *$count_Ascarina*\n";
print OUTFILE "Total number of *Ashbya* is *$count_Ashbya*\n";
print OUTFILE "Total number of *Aspergillus* is *$count_Aspergillus*\n";
print OUTFILE "Total number of *Asphodelus* is *$count_Asphodelus*\n";
print OUTFILE "Total number of *Aster* is *$count_Aster*\n";
print OUTFILE "Total number of *Asterina* is *$count_Asterina*\n";
print OUTFILE "Total number of *Atropa* is *$count_Atropa*\n";
print OUTFILE "Total number of *Aurantimonas* is *$count_Aurantimonas*\n";
print OUTFILE "Total number of *Austrobaileya* is *$count_Austrobaileya*\n";
print OUTFILE "Total number of *Azoarcus* is *$count_Azoarcus*\n";
print OUTFILE "Total number of *Azorhizobium* is *$count_Azorhizobium*\n";
print OUTFILE "Total number of *Azospirillum* is *$count_Azospirillum*\n";
print OUTFILE "Total number of *Azotobacter* is *$count_Azotobacter*\n";
print OUTFILE "Total number of *Babesia* is *$count_Babesia*\n";
print OUTFILE "Total number of *Bacteriophage* is *$count_Bacteriophage*\n";
print OUTFILE "Total number of *Bacteroides* is *$count_Bacteroides*\n";
print OUTFILE "Total number of *Balaenoptera* is *$count_Balaenoptera*\n";
print OUTFILE "Total number of *Barbarea* is *$count_Barbarea*\n";
print OUTFILE "Total number of *Bartonella* is *$count_Bartonella*\n";
print OUTFILE "Total number of *Baumannia* is *$count_Baumannia*\n";
print OUTFILE "Total number of *Bdellovibrio* is *$count_Bdellovibrio*\n";
print OUTFILE "Total number of *Beggiatoa* is *$count_Beggiatoa*\n";
print OUTFILE "Total number of *Bifidobacterium* is *$count_Bifidobacterium*\n";
print OUTFILE "Total number of *Bigelowiella* is *$count_Bigelowiella*\n";
print OUTFILE "Total number of *Bilophila* is *$count_Bilophila*\n";
print OUTFILE "Total number of *Bisgaard* is *$count_Bisgaard*\n";
print OUTFILE "Total number of *Blandfordia* is *$count_Blandfordia*\n";
print OUTFILE "Total number of *Blastopirellula* is *$count_Blastopirellula*\n";
print OUTFILE "Total number of *Bombyx* is *$count_Bombyx*\n";
print OUTFILE "Total number of *Bordetella* is *$count_Bordetella*\n";
print OUTFILE "Total number of *Borrelia* is *$count_Borrelia*\n";
print OUTFILE "Total number of *Bos* is *$count_Bos*\n";
print OUTFILE "Total number of *Botryotinia* is *$count_Botryotinia*\n";
print OUTFILE "Total number of *Bradyrhizobium* is *$count_Bradyrhizobium*\n";
print OUTFILE "Total number of *Brevibacterium* is *$count_Brevibacterium*\n";
print OUTFILE "Total number of *Brochothrix* is *$count_Brochothrix*\n";
print OUTFILE "Total number of *Brucella* is *$count_Brucella*\n";
print OUTFILE "Total number of *Brugia* is *$count_Brugia*\n";
print OUTFILE "Total number of *Bubalus* is *$count_Bubalus*\n";
print OUTFILE "Total number of *Buchnera* is *$count_Buchnera*\n";
print OUTFILE "Total number of *Burkholderia* is *$count_Burkholderia*\n";
print OUTFILE "Total number of *Burmannia* is *$count_Burmannia*\n";
print OUTFILE "Total number of *Buxus* is *$count_Buxus*\n";
print OUTFILE "Total number of *Cabomba* is *$count_Cabomba*\n";
print OUTFILE "Total number of *Caenorhabditis* is *$count_Caenorhabditis*\n";
print OUTFILE "Total number of *Caldibacillus* is *$count_Caldibacillus*\n";
print OUTFILE "Total number of *Caldicellulosiruptor* is *$count_Caldicellulosiruptor*\n";
print OUTFILE "Total number of *Callorhinchus* is *$count_Callorhinchus*\n";
print OUTFILE "Total number of *Calochortus* is *$count_Calochortus*\n";
print OUTFILE "Total number of *Calycanthus* is *$count_Calycanthus*\n";
print OUTFILE "Total number of *Caminibacter* is *$count_Caminibacter*\n";
print OUTFILE "Total number of *Campylobacter* is *$count_Campylobacter*\n";
print OUTFILE "Total number of *Candida* is *$count_Candida*\n";
print OUTFILE "Total number of *candidate* is *$count_candidate*\n";
print OUTFILE "Total number of *Candidatus* is *$count_Candidatus*\n";
print OUTFILE "Total number of *Canis* is *$count_Canis*\n";
print OUTFILE "Total number of *Capsella* is *$count_Capsella*\n";
print OUTFILE "Total number of *Carboxydothermus* is *$count_Carboxydothermus*\n";
print OUTFILE "Total number of *Cardinium* is *$count_Cardinium*\n";
print OUTFILE "Total number of *Cartonema* is *$count_Cartonema*\n";
print OUTFILE "Total number of *Caulobacter* is *$count_Caulobacter*\n";
print OUTFILE "Total number of *Cavia* is *$count_Cavia*\n";
print OUTFILE "Total number of *Cellulophaga* is *$count_Cellulophaga*\n";
print OUTFILE "Total number of *Cenarchaeum* is *$count_Cenarchaeum*\n";
print OUTFILE "Total number of *Centrolepis* is *$count_Centrolepis*\n";
print OUTFILE "Total number of *Cephaloscyllium* is *$count_Cephaloscyllium*\n";
print OUTFILE "Total number of *Ceratium* is *$count_Ceratium*\n";
print OUTFILE "Total number of *Ceratophyllum* is *$count_Ceratophyllum*\n";
print OUTFILE "Total number of *Ceratotherium* is *$count_Ceratotherium*\n";
print OUTFILE "Total number of *Cercidiphyllum* is *$count_Cercidiphyllum*\n";
print OUTFILE "Total number of *Cerebratulus* is *$count_Cerebratulus*\n";
print OUTFILE "Total number of *Chaetomium* is *$count_Chaetomium*\n";
print OUTFILE "Total number of *Chaetopterus* is *$count_Chaetopterus*\n";
print OUTFILE "Total number of *Chaetosphaeridium* is *$count_Chaetosphaeridium*\n";
print OUTFILE "Total number of *Chara* is *$count_Chara*\n";
print OUTFILE "Total number of *Chlamydia* is *$count_Chlamydia*\n";
print OUTFILE "Total number of *Chlamydomonas* is *$count_Chlamydomonas*\n";
print OUTFILE "Total number of *Chlamydophila* is *$count_Chlamydophila*\n";
print OUTFILE "Total number of *Chloranthus* is *$count_Chloranthus*\n";
print OUTFILE "Total number of *Chlorobium* is *$count_Chlorobium*\n";
print OUTFILE "Total number of *Chloroflexus* is *$count_Chloroflexus*\n";
print OUTFILE "Total number of *Chlorokybus* is *$count_Chlorokybus*\n";
print OUTFILE "Total number of *Chondromyces* is *$count_Chondromyces*\n";
print OUTFILE "Total number of *Chromobacterium* is *$count_Chromobacterium*\n";
print OUTFILE "Total number of *Chromohalobacter* is *$count_Chromohalobacter*\n";
print OUTFILE "Total number of *Citrobacter* is *$count_Citrobacter*\n";
print OUTFILE "Total number of *Citrus* is *$count_Citrus*\n";
print OUTFILE "Total number of *Clavibacter* is *$count_Clavibacter*\n";
print OUTFILE "Total number of *Cloning* is *$count_Cloning*\n";
print OUTFILE "Total number of *Clostridium* is *$count_Clostridium*\n";
print OUTFILE "Total number of *Coccidioides* is *$count_Coccidioides*\n";
print OUTFILE "Total number of *Coelogyne* is *$count_Coelogyne*\n";
print OUTFILE "Total number of *Coffea* is *$count_Coffea*\n";
print OUTFILE "Total number of *Collinsella* is *$count_Collinsella*\n";
print OUTFILE "Total number of *Colwellia* is *$count_Colwellia*\n";
print OUTFILE "Total number of *Comamonas* is *$count_Comamonas*\n";
print OUTFILE "Total number of *Convolvulus* is *$count_Convolvulus*\n";
print OUTFILE "Total number of *Coprinopsis* is *$count_Coprinopsis*\n";
print OUTFILE "Total number of *Coprococcus* is *$count_Coprococcus*\n";
print OUTFILE "Total number of *Corynebacterium* is *$count_Corynebacterium*\n";
print OUTFILE "Total number of *Coxiella* is *$count_Coxiella*\n";
print OUTFILE "Total number of *Crepidula* is *$count_Crepidula*\n";
print OUTFILE "Total number of *Croceibacter* is *$count_Croceibacter*\n";
print OUTFILE "Total number of *Crocosphaera* is *$count_Crocosphaera*\n";
print OUTFILE "Total number of *Crucihimalaya* is *$count_Crucihimalaya*\n";
print OUTFILE "Total number of *Cryptococcus* is *$count_Cryptococcus*\n";
print OUTFILE "Total number of *Cryptosporidium* is *$count_Cryptosporidium*\n";
print OUTFILE "Total number of *Cucumis* is *$count_Cucumis*\n";
print OUTFILE "Total number of *Cuscuta* is *$count_Cuscuta*\n";
print OUTFILE "Total number of *Cyanastrum* is *$count_Cyanastrum*\n";
print OUTFILE "Total number of *Cyanidioschyzon* is *$count_Cyanidioschyzon*\n";
print OUTFILE "Total number of *Cyanidium* is *$count_Cyanidium*\n";
print OUTFILE "Total number of *Cyanothece* is *$count_Cyanothece*\n";
print OUTFILE "Total number of *Cycas* is *$count_Cycas*\n";
print OUTFILE "Total number of *Cylindrococcus* is *$count_Cylindrococcus*\n";
print OUTFILE "Total number of *Cyperus* is *$count_Cyperus*\n";
print OUTFILE "Total number of *Cypripedium* is *$count_Cypripedium*\n";
print OUTFILE "Total number of *Cytophaga* is *$count_Cytophaga*\n";
print OUTFILE "Total number of *Daegunia* is *$count_Daegunia*\n";
print OUTFILE "Total number of *Danio* is *$count_Danio*\n";
print OUTFILE "Total number of *Daphniphyllum* is *$count_Daphniphyllum*\n";
print OUTFILE "Total number of *Dasypogon* is *$count_Dasypogon*\n";
print OUTFILE "Total number of *Daucus* is *$count_Daucus*\n";
print OUTFILE "Total number of *Debaryomyces* is *$count_Debaryomyces*\n";
print OUTFILE "Total number of *Dechloromonas* is *$count_Dechloromonas*\n";
print OUTFILE "Total number of *Dehalococcoides* is *$count_Dehalococcoides*\n";
print OUTFILE "Total number of *Deinococcus* is *$count_Deinococcus*\n";
print OUTFILE "Total number of *Delftia* is *$count_Delftia*\n";
print OUTFILE "Total number of *delta* is *$count_delta*\n";
print OUTFILE "Total number of *Desulfitobacterium* is *$count_Desulfitobacterium*\n";
print OUTFILE "Total number of *Desulfotalea* is *$count_Desulfotalea*\n";
print OUTFILE "Total number of *Desulfotomaculum* is *$count_Desulfotomaculum*\n";
print OUTFILE "Total number of *Desulfovibrio* is *$count_Desulfovibrio*\n";
print OUTFILE "Total number of *Desulfuromonas* is *$count_Desulfuromonas*\n";
print OUTFILE "Total number of *Desulfuromusa* is *$count_Desulfuromusa*\n";
print OUTFILE "Total number of *Dialister* is *$count_Dialister*\n";
print OUTFILE "Total number of *Diceros* is *$count_Diceros*\n";
print OUTFILE "Total number of *Dichelobacter* is *$count_Dichelobacter*\n";
print OUTFILE "Total number of *Dictyostelium* is *$count_Dictyostelium*\n";
print OUTFILE "Total number of *Dicyema* is *$count_Dicyema*\n";
print OUTFILE "Total number of *Didelphis* is *$count_Didelphis*\n";
print OUTFILE "Total number of *Dinoroseobacter* is *$count_Dinoroseobacter*\n";
print OUTFILE "Total number of *Dioscorea* is *$count_Dioscorea*\n";
print OUTFILE "Total number of *Dorea* is *$count_Dorea*\n";
print OUTFILE "Total number of *Draba* is *$count_Draba*\n";
print OUTFILE "Total number of *Drosophila* is *$count_Drosophila*\n";
print OUTFILE "Total number of *Ehrlichia* is *$count_Ehrlichia*\n";
print OUTFILE "Total number of *Elegia* is *$count_Elegia*\n";
print OUTFILE "Total number of *Emericella* is *$count_Emericella*\n";
print OUTFILE "Total number of *Encephalartos* is *$count_Encephalartos*\n";
print OUTFILE "Total number of *Endoriftia* is *$count_Endoriftia*\n";
print OUTFILE "Total number of *Ensete* is *$count_Ensete*\n";
print OUTFILE "Total number of *Entamoeba* is *$count_Entamoeba*\n";
print OUTFILE "Total number of *Enterobacter* is *$count_Enterobacter*\n";
print OUTFILE "Total number of *Enterobacteriaceae* is *$count_Enterobacteriaceae*\n";
print OUTFILE "Total number of *Enterococcus* is *$count_Enterococcus*\n";
print OUTFILE "Total number of *Entomoplasma* is *$count_Entomoplasma*\n";
print OUTFILE "Total number of *Ephydatia* is *$count_Ephydatia*\n";
print OUTFILE "Total number of *Equus* is *$count_Equus*\n";
print OUTFILE "Total number of *Erwinia* is *$count_Erwinia*\n";
print OUTFILE "Total number of *Erycibe* is *$count_Erycibe*\n";
print OUTFILE "Total number of *Erythrobacter* is *$count_Erythrobacter*\n";
print OUTFILE "Total number of *Escherichia* is *$count_Escherichia*\n";
print OUTFILE "Total number of *Eubacterium* is *$count_Eubacterium*\n";
print OUTFILE "Total number of *Eucalyptus* is *$count_Eucalyptus*\n";
print OUTFILE "Total number of *Exiguobacterium* is *$count_Exiguobacterium*\n";
print OUTFILE "Total number of *Faecalibacterium* is *$count_Faecalibacterium*\n";
print OUTFILE "Total number of *Falkia* is *$count_Falkia*\n";
print OUTFILE "Total number of *Fe]* is *$count_Fe]*\n";
print OUTFILE "Total number of *Felis* is *$count_Felis*\n";
print OUTFILE "Total number of *Ferroplasma* is *$count_Ferroplasma*\n";
print OUTFILE "Total number of *Fervidobacterium* is *$count_Fervidobacterium*\n";
print OUTFILE "Total number of *Flagellaria* is *$count_Flagellaria*\n";
print OUTFILE "Total number of *Flavobacteria* is *$count_Flavobacteria*\n";
print OUTFILE "Total number of *Flavobacteriales* is *$count_Flavobacteriales*\n";
print OUTFILE "Total number of *Flavobacterium* is *$count_Flavobacterium*\n";
print OUTFILE "Total number of *Fragaria* is *$count_Fragaria*\n";
print OUTFILE "Total number of *Francisella* is *$count_Francisella*\n";
print OUTFILE "Total number of *Frankia* is *$count_Frankia*\n";
print OUTFILE "Total number of *Fulvimarina* is *$count_Fulvimarina*\n";
print OUTFILE "Total number of *Fusobacterium* is *$count_Fusobacterium*\n";
print OUTFILE "Total number of *Gallus* is *$count_Gallus*\n";
print OUTFILE "Total number of *gamma* is *$count_gamma*\n";
print OUTFILE "Total number of *GenusX* is *$count_GenusX*\n";
print OUTFILE "Total number of *Geobacillus* is *$count_Geobacillus*\n";
print OUTFILE "Total number of *Geobacter* is *$count_Geobacter*\n";
print OUTFILE "Total number of *Giardia* is *$count_Giardia*\n";
print OUTFILE "Total number of *Gibberella* is *$count_Gibberella*\n";
print OUTFILE "Total number of *Ginkgo* is *$count_Ginkgo*\n";
print OUTFILE "Total number of *Gloeobacter* is *$count_Gloeobacter*\n";
print OUTFILE "Total number of *Gluconacetobacter* is *$count_Gluconacetobacter*\n";
print OUTFILE "Total number of *Gluconobacter* is *$count_Gluconobacter*\n";
print OUTFILE "Total number of *Glycine* is *$count_Glycine*\n";
print OUTFILE "Total number of *Gossypium* is *$count_Gossypium*\n";
print OUTFILE "Total number of *Gramella* is *$count_Gramella*\n";
print OUTFILE "Total number of *Granulibacter* is *$count_Granulibacter*\n";
print OUTFILE "Total number of *Granulicatella* is *$count_Granulicatella*\n";
print OUTFILE "Total number of *Gunnera* is *$count_Gunnera*\n";
print OUTFILE "Total number of *Haemophilus* is *$count_Haemophilus*\n";
print OUTFILE "Total number of *Hahella* is *$count_Hahella*\n";
print OUTFILE "Total number of *Haliotis* is *$count_Haliotis*\n";
print OUTFILE "Total number of *Halobacillus* is *$count_Halobacillus*\n";
print OUTFILE "Total number of *Haloquadratum* is *$count_Haloquadratum*\n";
print OUTFILE "Total number of *Halorhodospira* is *$count_Halorhodospira*\n";
print OUTFILE "Total number of *Halothermothrix* is *$count_Halothermothrix*\n";
print OUTFILE "Total number of *Hamamelis* is *$count_Hamamelis*\n";
print OUTFILE "Total number of *Helianthus* is *$count_Helianthus*\n";
print OUTFILE "Total number of *Helicobacter* is *$count_Helicobacter*\n";
print OUTFILE "Total number of *Helicoverpa* is *$count_Helicoverpa*\n";
print OUTFILE "Total number of *Heliobacillus* is *$count_Heliobacillus*\n";
print OUTFILE "Total number of *Helmholtzia* is *$count_Helmholtzia*\n";
print OUTFILE "Total number of *Hemerocallis* is *$count_Hemerocallis*\n";
print OUTFILE "Total number of *Herminiimonas* is *$count_Herminiimonas*\n";
print OUTFILE "Total number of *Herpetosiphon* is *$count_Herpetosiphon*\n";
print OUTFILE "Total number of *Heuchera* is *$count_Heuchera*\n";
print OUTFILE "Total number of *Hippopotamus* is *$count_Hippopotamus*\n";
print OUTFILE "Total number of *Homo* is *$count_Homo*\n";
print OUTFILE "Total number of *Humbertia* is *$count_Humbertia*\n";
print OUTFILE "Total number of *Huperzia* is *$count_Huperzia*\n";
print OUTFILE "Total number of *Hydrogenobaculum* is *$count_Hydrogenobaculum*\n";
print OUTFILE "Total number of *Hydrothrix* is *$count_Hydrothrix*\n";
print OUTFILE "Total number of *Hyphomicrobium* is *$count_Hyphomicrobium*\n";
print OUTFILE "Total number of *Hyphomonas* is *$count_Hyphomonas*\n";
print OUTFILE "Total number of *Idiomarina* is *$count_Idiomarina*\n";
print OUTFILE "Total number of *Illicium* is *$count_Illicium*\n";
print OUTFILE "Total number of *Ilyobacter* is *$count_Ilyobacter*\n";
print OUTFILE "Total number of *Includes* is *$count_Includes*\n";
print OUTFILE "Total number of *includes* is *$count_includes*\n";
print OUTFILE "Total number of *Ipomoea* is *$count_Ipomoea*\n";
print OUTFILE "Total number of *Iris* is *$count_Iris*\n";
print OUTFILE "Total number of *Iseia* is *$count_Iseia*\n";
print OUTFILE "Total number of *isomerizing]* is *$count_isomerizing]*\n";
print OUTFILE "Total number of *Jacquemontia* is *$count_Jacquemontia*\n";
print OUTFILE "Total number of *Janibacter* is *$count_Janibacter*\n";
print OUTFILE "Total number of *Jannaschia* is *$count_Jannaschia*\n";
print OUTFILE "Total number of *Janthinobacterium* is *$count_Janthinobacterium*\n";
print OUTFILE "Total number of *Japonolirion* is *$count_Japonolirion*\n";
print OUTFILE "Total number of *Jasminum* is *$count_Jasminum*\n";
print OUTFILE "Total number of *Kalanchoe* is *$count_Kalanchoe*\n";
print OUTFILE "Total number of *Kineococcus* is *$count_Kineococcus*\n";
print OUTFILE "Total number of *Klebsiella* is *$count_Klebsiella*\n";
print OUTFILE "Total number of *Kluyvera* is *$count_Kluyvera*\n";
print OUTFILE "Total number of *Kluyveromyces* is *$count_Kluyveromyces*\n";
print OUTFILE "Total number of *Kocuria* is *$count_Kocuria*\n";
print OUTFILE "Total number of *Kurthia* is *$count_Kurthia*\n";
print OUTFILE "Total number of *Laceyella* is *$count_Laceyella*\n";
print OUTFILE "Total number of *Lachnodius* is *$count_Lachnodius*\n";
print OUTFILE "Total number of *Lactobacillus* is *$count_Lactobacillus*\n";
print OUTFILE "Total number of *Lactococcus* is *$count_Lactococcus*\n";
print OUTFILE "Total number of *Lactoris* is *$count_Lactoris*\n";
print OUTFILE "Total number of *Lactuca* is *$count_Lactuca*\n";
print OUTFILE "Total number of *Larus* is *$count_Larus*\n";
print OUTFILE "Total number of *Lawsonia* is *$count_Lawsonia*\n";
print OUTFILE "Total number of *Legionella* is *$count_Legionella*\n";
print OUTFILE "Total number of *Leifsonia* is *$count_Leifsonia*\n";
print OUTFILE "Total number of *Leishmania* is *$count_Leishmania*\n";
print OUTFILE "Total number of *Lentisphaera* is *$count_Lentisphaera*\n";
print OUTFILE "Total number of *Lepidium* is *$count_Lepidium*\n";
print OUTFILE "Total number of *Lepidosiren* is *$count_Lepidosiren*\n";
print OUTFILE "Total number of *Lepidozamia* is *$count_Lepidozamia*\n";
print OUTFILE "Total number of *Lepisosteus* is *$count_Lepisosteus*\n";
print OUTFILE "Total number of *Lepistemon* is *$count_Lepistemon*\n";
print OUTFILE "Total number of *Leptosira* is *$count_Leptosira*\n";
print OUTFILE "Total number of *Leptospira* is *$count_Leptospira*\n";
print OUTFILE "Total number of *Leptospirillum* is *$count_Leptospirillum*\n";
print OUTFILE "Total number of *Lepus* is *$count_Lepus*\n";
print OUTFILE "Total number of *Lestes* is *$count_Lestes*\n";
print OUTFILE "Total number of *Lethenteron* is *$count_Lethenteron*\n";
print OUTFILE "Total number of *Leuconostoc* is *$count_Leuconostoc*\n";
print OUTFILE "Total number of *Leucosolenia* is *$count_Leucosolenia*\n";
print OUTFILE "Total number of *Lilium* is *$count_Lilium*\n";
print OUTFILE "Total number of *Limnobacter* is *$count_Limnobacter*\n";
print OUTFILE "Total number of *Lineus* is *$count_Lineus*\n";
print OUTFILE "Total number of *Liriodendron* is *$count_Liriodendron*\n";
print OUTFILE "Total number of *Listeria* is *$count_Listeria*\n";
print OUTFILE "Total number of *Lobularia* is *$count_Lobularia*\n";
print OUTFILE "Total number of *Lodderomyces* is *$count_Lodderomyces*\n";
print OUTFILE "Total number of *Loktanella* is *$count_Loktanella*\n";
print OUTFILE "Total number of *Lomandra* is *$count_Lomandra*\n";
print OUTFILE "Total number of *Lotus* is *$count_Lotus*\n";
print OUTFILE "Total number of *Loxodonta* is *$count_Loxodonta*\n";
print OUTFILE "Total number of *Lyngbya* is *$count_Lyngbya*\n";
print OUTFILE "Total number of *Maburea* is *$count_Maburea*\n";
print OUTFILE "Total number of *Macaca* is *$count_Macaca*\n";
print OUTFILE "Total number of *Maconellicoccus* is *$count_Maconellicoccus*\n";
print OUTFILE "Total number of *Macrozamia* is *$count_Macrozamia*\n";
print OUTFILE "Total number of *Magnaporthe* is *$count_Magnaporthe*\n";
print OUTFILE "Total number of *Magnetococcus* is *$count_Magnetococcus*\n";
print OUTFILE "Total number of *Magnetospirillum* is *$count_Magnetospirillum*\n";
print OUTFILE "Total number of *Malassezia* is *$count_Malassezia*\n";
print OUTFILE "Total number of *Mannheimia* is *$count_Mannheimia*\n";
print OUTFILE "Total number of *Maricaulis* is *$count_Maricaulis*\n";
print OUTFILE "Total number of *marine* is *$count_marine*\n";
print OUTFILE "Total number of *Marinibacillus* is *$count_Marinibacillus*\n";
print OUTFILE "Total number of *Marinobacter* is *$count_Marinobacter*\n";
print OUTFILE "Total number of *Marinomonas* is *$count_Marinomonas*\n";
print OUTFILE "Total number of *Maripa* is *$count_Maripa*\n";
print OUTFILE "Total number of *Mariprofundus* is *$count_Mariprofundus*\n";
print OUTFILE "Total number of *Medeola* is *$count_Medeola*\n";
print OUTFILE "Total number of *Medicago* is *$count_Medicago*\n";
print OUTFILE "Total number of *Meiothermus* is *$count_Meiothermus*\n";
print OUTFILE "Total number of *Meleagris* is *$count_Meleagris*\n";
print OUTFILE "Total number of *Merremia* is *$count_Merremia*\n";
print OUTFILE "Total number of *Mesocricetus* is *$count_Mesocricetus*\n";
print OUTFILE "Total number of *Mesoplasma* is *$count_Mesoplasma*\n";
print OUTFILE "Total number of *Mesorhizobium* is *$count_Mesorhizobium*\n";
print OUTFILE "Total number of *Mesostigma* is *$count_Mesostigma*\n";
print OUTFILE "Total number of *Methanobrevibacter* is *$count_Methanobrevibacter*\n";
print OUTFILE "Total number of *Methanocaldococcus* is *$count_Methanocaldococcus*\n";
print OUTFILE "Total number of *Methanococcus* is *$count_Methanococcus*\n";
print OUTFILE "Total number of *Methanocorpusculum* is *$count_Methanocorpusculum*\n";
print OUTFILE "Total number of *Methanoculleus* is *$count_Methanoculleus*\n";
print OUTFILE "Total number of *Methanopyrus* is *$count_Methanopyrus*\n";
print OUTFILE "Total number of *Methanosaeta* is *$count_Methanosaeta*\n";
print OUTFILE "Total number of *Methanosarcina* is *$count_Methanosarcina*\n";
print OUTFILE "Total number of *Methanothermobacter* is *$count_Methanothermobacter*\n";
print OUTFILE "Total number of *Methylibium* is *$count_Methylibium*\n";
print OUTFILE "Total number of *Methylobacillus* is *$count_Methylobacillus*\n";
print OUTFILE "Total number of *Methylobacterium* is *$count_Methylobacterium*\n";
print OUTFILE "Total number of *Methylocapsa* is *$count_Methylocapsa*\n";
print OUTFILE "Total number of *Methylococcus* is *$count_Methylococcus*\n";
print OUTFILE "Total number of *Methylophilales* is *$count_Methylophilales*\n";
print OUTFILE "Total number of *Metridium* is *$count_Metridium*\n";
print OUTFILE "Total number of *Microbacterium* is *$count_Microbacterium*\n";
print OUTFILE "Total number of *Microciona* is *$count_Microciona*\n";
print OUTFILE "Total number of *Microcystis* is *$count_Microcystis*\n";
print OUTFILE "Total number of *Microscilla* is *$count_Microscilla*\n";
print OUTFILE "Total number of *Modiolus* is *$count_Modiolus*\n";
print OUTFILE "Total number of *Monodelphis* is *$count_Monodelphis*\n";
print OUTFILE "Total number of *Monosiga* is *$count_Monosiga*\n";
print OUTFILE "Total number of *Montinia* is *$count_Montinia*\n";
print OUTFILE "Total number of *Moorella* is *$count_Moorella*\n";
print OUTFILE "Total number of *Morganella* is *$count_Morganella*\n";
print OUTFILE "Total number of *Moritella* is *$count_Moritella*\n";
print OUTFILE "Total number of *Morus* is *$count_Morus*\n";
print OUTFILE "Total number of *Muilla* is *$count_Muilla*\n";
print OUTFILE "Total number of *Mus* is *$count_Mus*\n";
print OUTFILE "Total number of *Musa* is *$count_Musa*\n";
print OUTFILE "Total number of *Mycobacterium* is *$count_Mycobacterium*\n";
print OUTFILE "Total number of *Mycoplasma* is *$count_Mycoplasma*\n";
print OUTFILE "Total number of *Myriophyllum* is *$count_Myriophyllum*\n";
print OUTFILE "Total number of *Mytilus* is *$count_Mytilus*\n";
print OUTFILE "Total number of *Myxococcus* is *$count_Myxococcus*\n";
print OUTFILE "Total number of *NADP+]* is *$count_NADP+]*\n";
print OUTFILE "Total number of *Nandina* is *$count_Nandina*\n";
print OUTFILE "Total number of *Narcissus* is *$count_Narcissus*\n";
print OUTFILE "Total number of *Narthecium* is *$count_Narthecium*\n";
print OUTFILE "Total number of *Nasonia* is *$count_Nasonia*\n";
print OUTFILE "Total number of *Nasturtium* is *$count_Nasturtium*\n";
print OUTFILE "Total number of *Natronomonas* is *$count_Natronomonas*\n";
print OUTFILE "Total number of *Neisseria* is *$count_Neisseria*\n";
print OUTFILE "Total number of *Nematostella* is *$count_Nematostella*\n";
print OUTFILE "Total number of *Neorickettsia* is *$count_Neorickettsia*\n";
print OUTFILE "Total number of *Neosartorya* is *$count_Neosartorya*\n";
print OUTFILE "Total number of *Neurospora* is *$count_Neurospora*\n";
print OUTFILE "Total number of *Nicotiana* is *$count_Nicotiana*\n";
print OUTFILE "Total number of *Nitratiruptor* is *$count_Nitratiruptor*\n";
print OUTFILE "Total number of *Nitrobacter* is *$count_Nitrobacter*\n";
print OUTFILE "Total number of *Nitrococcus* is *$count_Nitrococcus*\n";
print OUTFILE "Total number of *Nitrosococcus* is *$count_Nitrosococcus*\n";
print OUTFILE "Total number of *Nitrosomonas* is *$count_Nitrosomonas*\n";
print OUTFILE "Total number of *Nitrosospira* is *$count_Nitrosospira*\n";
print OUTFILE "Total number of *Nocardia* is *$count_Nocardia*\n";
print OUTFILE "Total number of *Nocardioides* is *$count_Nocardioides*\n";
print OUTFILE "Total number of *Nodularia* is *$count_Nodularia*\n";
print OUTFILE "Total number of *Nonomuraea* is *$count_Nonomuraea*\n";
print OUTFILE "Total number of *Nostoc* is *$count_Nostoc*\n";
print OUTFILE "Total number of *Notophthalmus* is *$count_Notophthalmus*\n";
print OUTFILE "Total number of *Novosphingobium* is *$count_Novosphingobium*\n";
print OUTFILE "Total number of *Nucula* is *$count_Nucula*\n";
print OUTFILE "Total number of *Nuphar* is *$count_Nuphar*\n";
print OUTFILE "Total number of *Nymphaea* is *$count_Nymphaea*\n";
print OUTFILE "Total number of *Obelia* is *$count_Obelia*\n";
print OUTFILE "Total number of *Oceanicaulis* is *$count_Oceanicaulis*\n";
print OUTFILE "Total number of *Oceanicola* is *$count_Oceanicola*\n";
print OUTFILE "Total number of *Oceanobacillus* is *$count_Oceanobacillus*\n";
print OUTFILE "Total number of *Oceanobacter* is *$count_Oceanobacter*\n";
print OUTFILE "Total number of *Oceanospirillum* is *$count_Oceanospirillum*\n";
print OUTFILE "Total number of *Ochrobactrum* is *$count_Ochrobactrum*\n";
print OUTFILE "Total number of *Odonellia* is *$count_Odonellia*\n";
print OUTFILE "Total number of *Odontella* is *$count_Odontella*\n";
print OUTFILE "Total number of *Oenococcus* is *$count_Oenococcus*\n";
print OUTFILE "Total number of *Olimarabidopsis* is *$count_Olimarabidopsis*\n";
print OUTFILE "Total number of *Olliffia* is *$count_Olliffia*\n";
print OUTFILE "Total number of *Onion* is *$count_Onion*\n";
print OUTFILE "Total number of *Opisthoscelis* is *$count_Opisthoscelis*\n";
print OUTFILE "Total number of *Opitutaceae* is *$count_Opitutaceae*\n";
print OUTFILE "Total number of *Orientia* is *$count_Orientia*\n";
print OUTFILE "Total number of *Orientobilharzia* is *$count_Orientobilharzia*\n";
print OUTFILE "Total number of *Ornithorhynchus* is *$count_Ornithorhynchus*\n";
print OUTFILE "Total number of *Oryctolagus* is *$count_Oryctolagus*\n";
print OUTFILE "Total number of *Oryza* is *$count_Oryza*\n";
print OUTFILE "Total number of *Oryzias* is *$count_Oryzias*\n";
print OUTFILE "Total number of *Ostreococcus* is *$count_Ostreococcus*\n";
print OUTFILE "Total number of *Paenibacillus* is *$count_Paenibacillus*\n";
print OUTFILE "Total number of *Paeonia* is *$count_Paeonia*\n";
print OUTFILE "Total number of *Pagrus* is *$count_Pagrus*\n";
print OUTFILE "Total number of *Pan* is *$count_Pan*\n";
print OUTFILE "Total number of *Panax* is *$count_Panax*\n";
print OUTFILE "Total number of *Papio* is *$count_Papio*\n";
print OUTFILE "Total number of *Parabacteroides* is *$count_Parabacteroides*\n";
print OUTFILE "Total number of *Paracoccus* is *$count_Paracoccus*\n";
print OUTFILE "Total number of *Paramecium* is *$count_Paramecium*\n";
print OUTFILE "Total number of *Parvibaculum* is *$count_Parvibaculum*\n";
print OUTFILE "Total number of *Parvularcula* is *$count_Parvularcula*\n";
print OUTFILE "Total number of *Pasteurella* is *$count_Pasteurella*\n";
print OUTFILE "Total number of *Pasteurellaceae* is *$count_Pasteurellaceae*\n";
print OUTFILE "Total number of *Pasteuria* is *$count_Pasteuria*\n";
print OUTFILE "Total number of *Peanut* is *$count_Peanut*\n";
print OUTFILE "Total number of *Pediococcus* is *$count_Pediococcus*\n";
print OUTFILE "Total number of *Pedobacter* is *$count_Pedobacter*\n";
print OUTFILE "Total number of *Pelobacter* is *$count_Pelobacter*\n";
print OUTFILE "Total number of *Pelodictyon* is *$count_Pelodictyon*\n";
print OUTFILE "Total number of *Pelotomaculum* is *$count_Pelotomaculum*\n";
print OUTFILE "Total number of *Penicillium* is *$count_Penicillium*\n";
print OUTFILE "Total number of *Penthorum* is *$count_Penthorum*\n";
print OUTFILE "Total number of *Peptococcus* is *$count_Peptococcus*\n";
print OUTFILE "Total number of *Peptostreptococcus* is *$count_Peptostreptococcus*\n";
print OUTFILE "Total number of *Peridiscus* is *$count_Peridiscus*\n";
print OUTFILE "Total number of *Petermannia* is *$count_Petermannia*\n";
print OUTFILE "Total number of *Petrotoga* is *$count_Petrotoga*\n";
print OUTFILE "Total number of *Phaeodactylum* is *$count_Phaeodactylum*\n";
print OUTFILE "Total number of *Phaeosphaeria* is *$count_Phaeosphaeria*\n";
print OUTFILE "Total number of *Phalaenopsis* is *$count_Phalaenopsis*\n";
print OUTFILE "Total number of *Phaseolus* is *$count_Phaseolus*\n";
print OUTFILE "Total number of *Phasianus* is *$count_Phasianus*\n";
print OUTFILE "Total number of *Philydrum* is *$count_Philydrum*\n";
print OUTFILE "Total number of *Phormium* is *$count_Phormium*\n";
print OUTFILE "Total number of *Photobacterium* is *$count_Photobacterium*\n";
print OUTFILE "Total number of *Photorhabdus* is *$count_Photorhabdus*\n";
print OUTFILE "Total number of *Phytophthora* is *$count_Phytophthora*\n";
print OUTFILE "Total number of *Pichia* is *$count_Pichia*\n";
print OUTFILE "Total number of *Picrophilus* is *$count_Picrophilus*\n";
print OUTFILE "Total number of *Piper* is *$count_Piper*\n";
print OUTFILE "Total number of *Pisum* is *$count_Pisum*\n";
print OUTFILE "Total number of *Planctomyces* is *$count_Planctomyces*\n";
print OUTFILE "Total number of *Plasmodium* is *$count_Plasmodium*\n";
print OUTFILE "Total number of *Platanus* is *$count_Platanus*\n";
print OUTFILE "Total number of *Plesiocystis* is *$count_Plesiocystis*\n";
print OUTFILE "Total number of *Podocarpus* is *$count_Podocarpus*\n";
print OUTFILE "Total number of *Poecilia* is *$count_Poecilia*\n";
print OUTFILE "Total number of *Polaribacter* is *$count_Polaribacter*\n";
print OUTFILE "Total number of *Polaromonas* is *$count_Polaromonas*\n";
print OUTFILE "Total number of *Polynucleobacter* is *$count_Polynucleobacter*\n";
print OUTFILE "Total number of *Polypterus* is *$count_Polypterus*\n";
print OUTFILE "Total number of *Polytomella* is *$count_Polytomella*\n";
print OUTFILE "Total number of *Pongo* is *$count_Pongo*\n";
print OUTFILE "Total number of *Populus* is *$count_Populus*\n";
print OUTFILE "Total number of *Porphyra* is *$count_Porphyra*\n";
print OUTFILE "Total number of *Porphyromonas* is *$count_Porphyromonas*\n";
print OUTFILE "Total number of *Priapulus* is *$count_Priapulus*\n";
print OUTFILE "Total number of *Prochlorococcus* is *$count_Prochlorococcus*\n";
print OUTFILE "Total number of *Propionibacterium* is *$count_Propionibacterium*\n";
print OUTFILE "Total number of *Prosartes* is *$count_Prosartes*\n";
print OUTFILE "Total number of *Prosthecochloris* is *$count_Prosthecochloris*\n";
print OUTFILE "Total number of *Proteus* is *$count_Proteus*\n";
print OUTFILE "Total number of *Protopterus* is *$count_Protopterus*\n";
print OUTFILE "Total number of *Prunus* is *$count_Prunus*\n";
print OUTFILE "Total number of *Pseudoalteromonas* is *$count_Pseudoalteromonas*\n";
print OUTFILE "Total number of *Pseudococcidae* is *$count_Pseudococcidae*\n";
print OUTFILE "Total number of *Pseudomonas* is *$count_Pseudomonas*\n";
print OUTFILE "Total number of *Psychrobacter* is *$count_Psychrobacter*\n";
print OUTFILE "Total number of *Psychroflexus* is *$count_Psychroflexus*\n";
print OUTFILE "Total number of *Psychromonas* is *$count_Psychromonas*\n";
print OUTFILE "Total number of *Pterostemon* is *$count_Pterostemon*\n";
print OUTFILE "Total number of *Pyrococcus* is *$count_Pyrococcus*\n";
print OUTFILE "Total number of *Ralstonia* is *$count_Ralstonia*\n";
print OUTFILE "Total number of *Rana* is *$count_Rana*\n";
print OUTFILE "Total number of *Ranunculus* is *$count_Ranunculus*\n";
print OUTFILE "Total number of *Raoultella* is *$count_Raoultella*\n";
print OUTFILE "Total number of *Rapona* is *$count_Rapona*\n";
print OUTFILE "Total number of *Rattus* is *$count_Rattus*\n";
print OUTFILE "Total number of *Reinekea* is *$count_Reinekea*\n";
print OUTFILE "Total number of *Rheum* is *$count_Rheum*\n";
print OUTFILE "Total number of *Rhizobium* is *$count_Rhizobium*\n";
print OUTFILE "Total number of *Rhodobacter* is *$count_Rhodobacter*\n";
print OUTFILE "Total number of *Rhodobacterales* is *$count_Rhodobacterales*\n";
print OUTFILE "Total number of *Rhodococcus* is *$count_Rhodococcus*\n";
print OUTFILE "Total number of *Rhodoferax* is *$count_Rhodoferax*\n";
print OUTFILE "Total number of *Rhodomonas* is *$count_Rhodomonas*\n";
print OUTFILE "Total number of *Rhodopirellula* is *$count_Rhodopirellula*\n";
print OUTFILE "Total number of *Rhodopseudomonas* is *$count_Rhodopseudomonas*\n";
print OUTFILE "Total number of *Rhodospirillum* is *$count_Rhodospirillum*\n";
print OUTFILE "Total number of *Ribes* is *$count_Ribes*\n";
print OUTFILE "Total number of *Rickettsia* is *$count_Rickettsia*\n";
print OUTFILE "Total number of *Rickettsiella* is *$count_Rickettsiella*\n";
print OUTFILE "Total number of *Robiginitalea* is *$count_Robiginitalea*\n";
print OUTFILE "Total number of *Roseiflexus* is *$count_Roseiflexus*\n";
print OUTFILE "Total number of *Roseobacter* is *$count_Roseobacter*\n";
print OUTFILE "Total number of *Roseovarius* is *$count_Roseovarius*\n";
print OUTFILE "Total number of *Rubrobacter* is *$count_Rubrobacter*\n";
print OUTFILE "Total number of *Ruminococcus* is *$count_Ruminococcus*\n";
print OUTFILE "Total number of *Saccharomyces* is *$count_Saccharomyces*\n";
print OUTFILE "Total number of *Saccharophagus* is *$count_Saccharophagus*\n";
print OUTFILE "Total number of *Saccharopolyspora* is *$count_Saccharopolyspora*\n";
print OUTFILE "Total number of *Saccoglossus* is *$count_Saccoglossus*\n";
print OUTFILE "Total number of *Sagittula* is *$count_Sagittula*\n";
print OUTFILE "Total number of *Salinibacter* is *$count_Salinibacter*\n";
print OUTFILE "Total number of *Salinispora* is *$count_Salinispora*\n";
print OUTFILE "Total number of *Salinivibrio* is *$count_Salinivibrio*\n";
print OUTFILE "Total number of *Salmonella* is *$count_Salmonella*\n";
print OUTFILE "Total number of *Sarcophaga* is *$count_Sarcophaga*\n";
print OUTFILE "Total number of *Saururus* is *$count_Saururus*\n";
print OUTFILE "Total number of *Saxegothaea* is *$count_Saxegothaea*\n";
print OUTFILE "Total number of *Saxifraga* is *$count_Saxifraga*\n";
print OUTFILE "Total number of *Scheuchzeria* is *$count_Scheuchzeria*\n";
print OUTFILE "Total number of *Schisandra* is *$count_Schisandra*\n";
print OUTFILE "Total number of *Schistosoma* is *$count_Schistosoma*\n";
print OUTFILE "Total number of *Schizanthus* is *$count_Schizanthus*\n";
print OUTFILE "Total number of *Sciadopitys* is *$count_Sciadopitys*\n";
print OUTFILE "Total number of *Sclerotinia* is *$count_Sclerotinia*\n";
print OUTFILE "Total number of *Scyliorhinus* is *$count_Scyliorhinus*\n";
print OUTFILE "Total number of *Serratia* is *$count_Serratia*\n";
print OUTFILE "Total number of *Shewanella* is *$count_Shewanella*\n";
print OUTFILE "Total number of *Shigella* is *$count_Shigella*\n";
print OUTFILE "Total number of *Silicibacter* is *$count_Silicibacter*\n";
print OUTFILE "Total number of *similarity]* is *$count_similarity]*\n";
print OUTFILE "Total number of *Sinorhizobium* is *$count_Sinorhizobium*\n";
print OUTFILE "Total number of *Smilacina* is *$count_Smilacina*\n";
print OUTFILE "Total number of *Smilax* is *$count_Smilax*\n";
print OUTFILE "Total number of *Sminthopsis* is *$count_Sminthopsis*\n";
print OUTFILE "Total number of *Sodalis* is *$count_Sodalis*\n";
print OUTFILE "Total number of *Solanum* is *$count_Solanum*\n";
print OUTFILE "Total number of *Solibacter* is *$count_Solibacter*\n";
print OUTFILE "Total number of *Spathiphyllum* is *$count_Spathiphyllum*\n";
print OUTFILE "Total number of *Sphaerococcopsis* is *$count_Sphaerococcopsis*\n";
print OUTFILE "Total number of *Sphingomonas* is *$count_Sphingomonas*\n";
print OUTFILE "Total number of *Sphingopyxis* is *$count_Sphingopyxis*\n";
print OUTFILE "Total number of *Spinacia* is *$count_Spinacia*\n";
print OUTFILE "Total number of *Spiroplasma* is *$count_Spiroplasma*\n";
print OUTFILE "Total number of *Sporosarcina* is *$count_Sporosarcina*\n";
print OUTFILE "Total number of *Staphylococcus* is *$count_Staphylococcus*\n";
print OUTFILE "Total number of *Stappia* is *$count_Stappia*\n";
print OUTFILE "Total number of *Stemona* is *$count_Stemona*\n";
print OUTFILE "Total number of *Stenotrophomonas* is *$count_Stenotrophomonas*\n";
print OUTFILE "Total number of *Stigeoclonium* is *$count_Stigeoclonium*\n";
print OUTFILE "Total number of *Stigmatella* is *$count_Stigmatella*\n";
print OUTFILE "Total number of *Streptobacillus* is *$count_Streptobacillus*\n";
print OUTFILE "Total number of *Streptococcus* is *$count_Streptococcus*\n";
print OUTFILE "Total number of *Streptomyces* is *$count_Streptomyces*\n";
print OUTFILE "Total number of *Strongylocentrotus* is *$count_Strongylocentrotus*\n";
print OUTFILE "Total number of *Stylochus* is *$count_Stylochus*\n";
print OUTFILE "Total number of *Sulfitobacter* is *$count_Sulfitobacter*\n";
print OUTFILE "Total number of *Sulfurovum* is *$count_Sulfurovum*\n";
print OUTFILE "Total number of *Sus* is *$count_Sus*\n";
print OUTFILE "Total number of *swine* is *$count_swine*\n";
print OUTFILE "Total number of *Sycon* is *$count_Sycon*\n";
print OUTFILE "Total number of *Symbiobacterium* is *$count_Symbiobacterium*\n";
print OUTFILE "Total number of *Synechococcus* is *$count_Synechococcus*\n";
print OUTFILE "Total number of *Synechocystis* is *$count_Synechocystis*\n";
print OUTFILE "Total number of *synthetic* is *$count_synthetic*\n";
print OUTFILE "Total number of *Syntrophobacter* is *$count_Syntrophobacter*\n";
print OUTFILE "Total number of *Syntrophomonas* is *$count_Syntrophomonas*\n";
print OUTFILE "Total number of *Syntrophus* is *$count_Syntrophus*\n";
print OUTFILE "Total number of *Tadarida* is *$count_Tadarida*\n";
print OUTFILE "Total number of *Talbotia* is *$count_Talbotia*\n";
print OUTFILE "Total number of *Tenacibaculum* is *$count_Tenacibaculum*\n";
print OUTFILE "Total number of *Tenebrio* is *$count_Tenebrio*\n";
print OUTFILE "Total number of *Tetragenococcus* is *$count_Tetragenococcus*\n";
print OUTFILE "Total number of *Tetrahymena* is *$count_Tetrahymena*\n";
print OUTFILE "Total number of *Tetraodon* is *$count_Tetraodon*\n";
print OUTFILE "Total number of *Thalassiosira* is *$count_Thalassiosira*\n";
print OUTFILE "Total number of *Theileria* is *$count_Theileria*\n";
print OUTFILE "Total number of *Thermoactinomyces* is *$count_Thermoactinomyces*\n";
print OUTFILE "Total number of *Thermoanaerobacter* is *$count_Thermoanaerobacter*\n";
print OUTFILE "Total number of *Thermobifida* is *$count_Thermobifida*\n";
print OUTFILE "Total number of *Thermococcus* is *$count_Thermococcus*\n";
print OUTFILE "Total number of *Thermoflavimicrobium* is *$count_Thermoflavimicrobium*\n";
print OUTFILE "Total number of *Thermoplasma* is *$count_Thermoplasma*\n";
print OUTFILE "Total number of *Thermosinus* is *$count_Thermosinus*\n";
print OUTFILE "Total number of *Thermosipho* is *$count_Thermosipho*\n";
print OUTFILE "Total number of *Thermosynechococcus* is *$count_Thermosynechococcus*\n";
print OUTFILE "Total number of *Thermotoga* is *$count_Thermotoga*\n";
print OUTFILE "Total number of *Thermus* is *$count_Thermus*\n";
print OUTFILE "Total number of *Thiobacillus* is *$count_Thiobacillus*\n";
print OUTFILE "Total number of *Thiomicrospira* is *$count_Thiomicrospira*\n";
print OUTFILE "Total number of *Tissierella* is *$count_Tissierella*\n";
print OUTFILE "Total number of *Tofieldia* is *$count_Tofieldia*\n";
print OUTFILE "Total number of *Treponema* is *$count_Treponema*\n";
print OUTFILE "Total number of *Tribolium* is *$count_Tribolium*\n";
print OUTFILE "Total number of *Trichodesmium* is *$count_Trichodesmium*\n";
print OUTFILE "Total number of *Trichomonas* is *$count_Trichomonas*\n";
print OUTFILE "Total number of *Tricyrtis* is *$count_Tricyrtis*\n";
print OUTFILE "Total number of *Trillium* is *$count_Trillium*\n";
print OUTFILE "Total number of *Trithuria* is *$count_Trithuria*\n";
print OUTFILE "Total number of *Trochodendron* is *$count_Trochodendron*\n";
print OUTFILE "Total number of *Trochospongilla* is *$count_Trochospongilla*\n";
print OUTFILE "Total number of *Tropheryma* is *$count_Tropheryma*\n";
print OUTFILE "Total number of *Trypanosoma* is *$count_Trypanosoma*\n";
print OUTFILE "Total number of *Tupaia* is *$count_Tupaia*\n";
print OUTFILE "Total number of *Typha* is *$count_Typha*\n";
print OUTFILE "Total number of *uncultured* is *$count_uncultured*\n";
print OUTFILE "Total number of *unidentified* is *$count_unidentified*\n";
print OUTFILE "Total number of *Ureaplasma* is *$count_Ureaplasma*\n";
print OUTFILE "Total number of *Ustilago* is *$count_Ustilago*\n";
print OUTFILE "Total number of *Vagococcus* is *$count_Vagococcus*\n";
print OUTFILE "Total number of *Vanderwaltozyma* is *$count_Vanderwaltozyma*\n";
print OUTFILE "Total number of *Veillonella* is *$count_Veillonella*\n";
print OUTFILE "Total number of *Verminephrobacter* is *$count_Verminephrobacter*\n";
print OUTFILE "Total number of *Vibrio* is *$count_Vibrio*\n";
print OUTFILE "Total number of *Vibrionales* is *$count_Vibrionales*\n";
print OUTFILE "Total number of *Victivallis* is *$count_Victivallis*\n";
print OUTFILE "Total number of *Virgibacillus* is *$count_Virgibacillus*\n";
print OUTFILE "Total number of *Vitis* is *$count_Vitis*\n";
print OUTFILE "Total number of *Weissella* is *$count_Weissella*\n";
print OUTFILE "Total number of *Wigglesworthia* is *$count_Wigglesworthia*\n";
print OUTFILE "Total number of *Wolbachia* is *$count_Wolbachia*\n";
print OUTFILE "Total number of *Wolinella* is *$count_Wolinella*\n";
print OUTFILE "Total number of *Xanthobacter* is *$count_Xanthobacter*\n";
print OUTFILE "Total number of *Xanthomonas* is *$count_Xanthomonas*\n";
print OUTFILE "Total number of *Xanthorrhoea* is *$count_Xanthorrhoea*\n";
print OUTFILE "Total number of *Xenopus* is *$count_Xenopus*\n";
print OUTFILE "Total number of *Xeronema* is *$count_Xeronema*\n";
print OUTFILE "Total number of *Xiphidium* is *$count_Xiphidium*\n";
print OUTFILE "Total number of *Xiphophorus* is *$count_Xiphophorus*\n";
print OUTFILE "Total number of *Xylella* is *$count_Xylella*\n";
print OUTFILE "Total number of *Xyris* is *$count_Xyris*\n";
print OUTFILE "Total number of *Yarrowia* is *$count_Yarrowia*\n";
print OUTFILE "Total number of *Yersinia* is *$count_Yersinia*\n";
print OUTFILE "Total number of *Yucca* is *$count_Yucca*\n";
print OUTFILE "Total number of *Zymomonas* is *$count_Zymomonas*\n";
print OUTFILE "Total number of *Zymomonas* is *$count_Zymomonas*\n";


#number of miscallaneous proteins
#$misc =$count_gi - ($count_transp +$count_drug +$count_adhes +$count_hypoth +$count_toxin +$count_flag +$count_protea +$count_motil +$count_cap +$count_perm +$count_reg +$count_tax +$count_kin +$count_dehy +$count_side);


#print OUTFILE "-------------- OTHERS -------------- \n";
#print OUTFILE "Total number of *miscallaneous proteins* (i.e other non-classified proteins) = *$misc*";
close(OUTFILE) or die ("Cannot close file : $!");                                                                                                     
print "Open file_length.txt\n";