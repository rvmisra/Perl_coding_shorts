#simple NEXUS script

print "#NEXUS\n";
print "Begin trees;\n";
print "Translate\n";
print "\t1 F_nodosum,\n";
print "\t2 P_mobilis,\n";
print "\t3 Thermosipho,\n";
print "\t4 T_lettingae,\n";
print "\t5 T_maritima,\n";
print "\t6 T_petrophila,\n";
print "\t7 T_RQ2\n";
print "\t;\n";

$i = 1;

while (<>) {
    print "tree t$i = [&U] $_";
    $i++;
}
print "End;\n\n";

