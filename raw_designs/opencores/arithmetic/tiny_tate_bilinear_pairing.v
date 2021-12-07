/*
 * Copyright 2012, Homer Hsing <homer.hsing@gmail.com>
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 * http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */

`define M     593         // M is the degree of the irreducible polynomial
`define WIDTH (2*`M-1)    // width for a GF(3^M) element
`define WIDTH_D0 1187

/*
 * the module of constants
 *
 * addr  out  effective
 *    1   0     1
 *    2   1     1
 *    4   +     1
 *    8   -     1
 *   16 cubic   1
 * other  0     0
 */
module const_ (clk, addr, out, effective);
    input clk;
    input [5:0] addr;
    output reg [`WIDTH_D0:0] out;
    output reg effective; // active high if out is effective
    
    always @ (posedge clk)
      begin
         effective <= 1;
         case (addr)
            1:  out <= 0;
            2:  out <= 1;
            4:  out <= {6'b000101, 1182'd0};
            8:  out <= {6'b001001, 1182'd0};
            16: out <= {6'b010101, 1182'd0};
            default: 
               begin out <= 0; effective <= 0; end
         endcase
      end
endmodule
/*
 * Copyright 2012, Homer Hsing <homer.hsing@gmail.com>
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 * http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */

/* v0(a)+v1(a)+v2(a) == a^3 in GF(3^m) */

/* c == v0(a) */
module v0(a, c);
    input [1185:0] a;
    output [1185:0] c;
    assign c[1:0] = a[1:0];
    assign c[3:2] = a[1113:1112];
    assign c[5:4] = a[793:792];
    assign c[7:6] = a[3:2];
    assign c[9:8] = a[1115:1114];
    assign c[11:10] = a[1041:1040];
    assign c[13:12] = {a[720], a[721]};
    assign c[15:14] = a[401:400];
    assign c[17:16] = a[1043:1042];
    assign c[19:18] = {a[722], a[723]};
    assign c[21:20] = a[403:402];
    assign c[23:22] = a[1045:1044];
    assign c[25:24] = {a[724], a[725]};
    assign c[27:26] = a[1121:1120];
    assign c[29:28] = a[801:800];
    assign c[31:30] = {a[726], a[727]};
    assign c[33:32] = a[1123:1122];
    assign c[35:34] = a[803:802];
    assign c[37:36] = {a[728], a[729]};
    assign c[39:38] = a[1125:1124];
    assign c[41:40] = a[805:804];
    assign c[43:42] = {a[730], a[731]};
    assign c[45:44] = a[1127:1126];
    assign c[47:46] = a[807:806];
    assign c[49:48] = a[17:16];
    assign c[51:50] = a[1129:1128];
    assign c[53:52] = a[809:808];
    assign c[55:54] = a[19:18];
    assign c[57:56] = a[1131:1130];
    assign c[59:58] = a[1057:1056];
    assign c[61:60] = {a[736], a[737]};
    assign c[63:62] = a[417:416];
    assign c[65:64] = a[1059:1058];
    assign c[67:66] = {a[738], a[739]};
    assign c[69:68] = a[419:418];
    assign c[71:70] = a[1061:1060];
    assign c[73:72] = {a[740], a[741]};
    assign c[75:74] = a[1137:1136];
    assign c[77:76] = a[817:816];
    assign c[79:78] = {a[742], a[743]};
    assign c[81:80] = a[1139:1138];
    assign c[83:82] = a[819:818];
    assign c[85:84] = {a[744], a[745]};
    assign c[87:86] = a[1141:1140];
    assign c[89:88] = a[821:820];
    assign c[91:90] = {a[746], a[747]};
    assign c[93:92] = a[1143:1142];
    assign c[95:94] = a[823:822];
    assign c[97:96] = a[33:32];
    assign c[99:98] = a[1145:1144];
    assign c[101:100] = a[825:824];
    assign c[103:102] = a[35:34];
    assign c[105:104] = a[1147:1146];
    assign c[107:106] = a[1073:1072];
    assign c[109:108] = {a[752], a[753]};
    assign c[111:110] = a[433:432];
    assign c[113:112] = a[1075:1074];
    assign c[115:114] = {a[754], a[755]};
    assign c[117:116] = a[435:434];
    assign c[119:118] = a[1077:1076];
    assign c[121:120] = {a[756], a[757]};
    assign c[123:122] = a[1153:1152];
    assign c[125:124] = a[833:832];
    assign c[127:126] = {a[758], a[759]};
    assign c[129:128] = a[1155:1154];
    assign c[131:130] = a[835:834];
    assign c[133:132] = {a[760], a[761]};
    assign c[135:134] = a[1157:1156];
    assign c[137:136] = a[837:836];
    assign c[139:138] = {a[762], a[763]};
    assign c[141:140] = a[1159:1158];
    assign c[143:142] = a[839:838];
    assign c[145:144] = a[49:48];
    assign c[147:146] = a[1161:1160];
    assign c[149:148] = a[841:840];
    assign c[151:150] = a[51:50];
    assign c[153:152] = a[1163:1162];
    assign c[155:154] = a[1089:1088];
    assign c[157:156] = {a[768], a[769]};
    assign c[159:158] = a[449:448];
    assign c[161:160] = a[1091:1090];
    assign c[163:162] = {a[770], a[771]};
    assign c[165:164] = a[451:450];
    assign c[167:166] = a[1093:1092];
    assign c[169:168] = {a[772], a[773]};
    assign c[171:170] = a[1169:1168];
    assign c[173:172] = a[849:848];
    assign c[175:174] = {a[774], a[775]};
    assign c[177:176] = a[1171:1170];
    assign c[179:178] = a[851:850];
    assign c[181:180] = {a[776], a[777]};
    assign c[183:182] = a[1173:1172];
    assign c[185:184] = a[853:852];
    assign c[187:186] = {a[778], a[779]};
    assign c[189:188] = a[1175:1174];
    assign c[191:190] = a[855:854];
    assign c[193:192] = a[65:64];
    assign c[195:194] = a[1177:1176];
    assign c[197:196] = a[857:856];
    assign c[199:198] = a[67:66];
    assign c[201:200] = a[1179:1178];
    assign c[203:202] = a[1105:1104];
    assign c[205:204] = {a[784], a[785]};
    assign c[207:206] = a[465:464];
    assign c[209:208] = a[1107:1106];
    assign c[211:210] = {a[786], a[787]};
    assign c[213:212] = a[467:466];
    assign c[215:214] = a[1109:1108];
    assign c[217:216] = {a[788], a[789]};
    assign c[219:218] = a[1185:1184];
    assign c[221:220] = a[865:864];
    assign c[223:222] = {a[790], a[791]};
    assign c[225:224] = a[471:470];
    assign c[227:226] = a[867:866];
    assign c[229:228] = a[793:792];
    assign c[231:230] = a[473:472];
    assign c[233:232] = a[869:868];
    assign c[235:234] = {a[1040], a[1041]};
    assign c[237:236] = a[721:720];
    assign c[239:238] = {a[400], a[401]};
    assign c[241:240] = a[81:80];
    assign c[243:242] = a[723:722];
    assign c[245:244] = {a[402], a[403]};
    assign c[247:246] = a[83:82];
    assign c[249:248] = a[725:724];
    assign c[251:250] = {a[404], a[405]};
    assign c[253:252] = a[801:800];
    assign c[255:254] = a[481:480];
    assign c[257:256] = {a[406], a[407]};
    assign c[259:258] = a[803:802];
    assign c[261:260] = a[483:482];
    assign c[263:262] = {a[408], a[409]};
    assign c[265:264] = a[805:804];
    assign c[267:266] = a[485:484];
    assign c[269:268] = a[881:880];
    assign c[271:270] = a[807:806];
    assign c[273:272] = a[487:486];
    assign c[275:274] = a[883:882];
    assign c[277:276] = a[809:808];
    assign c[279:278] = a[489:488];
    assign c[281:280] = a[885:884];
    assign c[283:282] = {a[1056], a[1057]};
    assign c[285:284] = a[737:736];
    assign c[287:286] = {a[416], a[417]};
    assign c[289:288] = a[97:96];
    assign c[291:290] = a[739:738];
    assign c[293:292] = {a[418], a[419]};
    assign c[295:294] = a[99:98];
    assign c[297:296] = a[741:740];
    assign c[299:298] = {a[420], a[421]};
    assign c[301:300] = a[817:816];
    assign c[303:302] = a[497:496];
    assign c[305:304] = {a[422], a[423]};
    assign c[307:306] = a[819:818];
    assign c[309:308] = a[499:498];
    assign c[311:310] = {a[424], a[425]};
    assign c[313:312] = a[821:820];
    assign c[315:314] = a[501:500];
    assign c[317:316] = a[897:896];
    assign c[319:318] = a[823:822];
    assign c[321:320] = a[503:502];
    assign c[323:322] = a[899:898];
    assign c[325:324] = a[825:824];
    assign c[327:326] = a[505:504];
    assign c[329:328] = a[901:900];
    assign c[331:330] = {a[1072], a[1073]};
    assign c[333:332] = a[753:752];
    assign c[335:334] = {a[432], a[433]};
    assign c[337:336] = a[113:112];
    assign c[339:338] = a[755:754];
    assign c[341:340] = {a[434], a[435]};
    assign c[343:342] = a[115:114];
    assign c[345:344] = a[757:756];
    assign c[347:346] = {a[436], a[437]};
    assign c[349:348] = a[833:832];
    assign c[351:350] = a[513:512];
    assign c[353:352] = {a[438], a[439]};
    assign c[355:354] = a[835:834];
    assign c[357:356] = a[515:514];
    assign c[359:358] = {a[440], a[441]};
    assign c[361:360] = a[837:836];
    assign c[363:362] = a[517:516];
    assign c[365:364] = a[913:912];
    assign c[367:366] = a[839:838];
    assign c[369:368] = a[519:518];
    assign c[371:370] = a[915:914];
    assign c[373:372] = a[841:840];
    assign c[375:374] = a[521:520];
    assign c[377:376] = a[917:916];
    assign c[379:378] = {a[1088], a[1089]};
    assign c[381:380] = a[769:768];
    assign c[383:382] = {a[448], a[449]};
    assign c[385:384] = a[129:128];
    assign c[387:386] = a[771:770];
    assign c[389:388] = {a[450], a[451]};
    assign c[391:390] = a[131:130];
    assign c[393:392] = a[773:772];
    assign c[395:394] = {a[452], a[453]};
    assign c[397:396] = a[849:848];
    assign c[399:398] = a[529:528];
    assign c[401:400] = {a[454], a[455]};
    assign c[403:402] = a[851:850];
    assign c[405:404] = a[531:530];
    assign c[407:406] = {a[456], a[457]};
    assign c[409:408] = a[853:852];
    assign c[411:410] = a[533:532];
    assign c[413:412] = a[929:928];
    assign c[415:414] = a[855:854];
    assign c[417:416] = a[535:534];
    assign c[419:418] = a[931:930];
    assign c[421:420] = a[857:856];
    assign c[423:422] = a[537:536];
    assign c[425:424] = a[933:932];
    assign c[427:426] = {a[1104], a[1105]};
    assign c[429:428] = a[785:784];
    assign c[431:430] = {a[464], a[465]};
    assign c[433:432] = a[145:144];
    assign c[435:434] = a[787:786];
    assign c[437:436] = {a[466], a[467]};
    assign c[439:438] = a[147:146];
    assign c[441:440] = a[789:788];
    assign c[443:442] = {a[468], a[469]};
    assign c[445:444] = a[865:864];
    assign c[447:446] = a[545:544];
    assign c[449:448] = {a[470], a[471]};
    assign c[451:450] = a[867:866];
    assign c[453:452] = a[547:546];
    assign c[455:454] = {a[472], a[473]};
    assign c[457:456] = a[869:868];
    assign c[459:458] = a[549:548];
    assign c[461:460] = a[945:944];
    assign c[463:462] = a[871:870];
    assign c[465:464] = a[551:550];
    assign c[467:466] = a[947:946];
    assign c[469:468] = a[873:872];
    assign c[471:470] = a[553:552];
    assign c[473:472] = a[949:948];
    assign c[475:474] = {a[1120], a[1121]};
    assign c[477:476] = a[801:800];
    assign c[479:478] = {a[480], a[481]};
    assign c[481:480] = a[161:160];
    assign c[483:482] = a[803:802];
    assign c[485:484] = {a[482], a[483]};
    assign c[487:486] = a[163:162];
    assign c[489:488] = a[805:804];
    assign c[491:490] = {a[484], a[485]};
    assign c[493:492] = a[881:880];
    assign c[495:494] = a[561:560];
    assign c[497:496] = {a[486], a[487]};
    assign c[499:498] = a[883:882];
    assign c[501:500] = a[563:562];
    assign c[503:502] = {a[488], a[489]};
    assign c[505:504] = a[885:884];
    assign c[507:506] = a[565:564];
    assign c[509:508] = a[961:960];
    assign c[511:510] = a[887:886];
    assign c[513:512] = a[567:566];
    assign c[515:514] = a[963:962];
    assign c[517:516] = a[889:888];
    assign c[519:518] = a[569:568];
    assign c[521:520] = a[965:964];
    assign c[523:522] = {a[1136], a[1137]};
    assign c[525:524] = a[817:816];
    assign c[527:526] = {a[496], a[497]};
    assign c[529:528] = a[177:176];
    assign c[531:530] = a[819:818];
    assign c[533:532] = {a[498], a[499]};
    assign c[535:534] = a[179:178];
    assign c[537:536] = a[821:820];
    assign c[539:538] = {a[500], a[501]};
    assign c[541:540] = a[897:896];
    assign c[543:542] = a[577:576];
    assign c[545:544] = {a[502], a[503]};
    assign c[547:546] = a[899:898];
    assign c[549:548] = a[579:578];
    assign c[551:550] = {a[504], a[505]};
    assign c[553:552] = a[901:900];
    assign c[555:554] = a[581:580];
    assign c[557:556] = a[977:976];
    assign c[559:558] = a[903:902];
    assign c[561:560] = a[583:582];
    assign c[563:562] = a[979:978];
    assign c[565:564] = a[905:904];
    assign c[567:566] = a[585:584];
    assign c[569:568] = a[981:980];
    assign c[571:570] = {a[1152], a[1153]};
    assign c[573:572] = a[833:832];
    assign c[575:574] = {a[512], a[513]};
    assign c[577:576] = a[193:192];
    assign c[579:578] = a[835:834];
    assign c[581:580] = {a[514], a[515]};
    assign c[583:582] = a[195:194];
    assign c[585:584] = a[837:836];
    assign c[587:586] = {a[516], a[517]};
    assign c[589:588] = a[913:912];
    assign c[591:590] = a[593:592];
    assign c[593:592] = {a[518], a[519]};
    assign c[595:594] = a[915:914];
    assign c[597:596] = a[595:594];
    assign c[599:598] = {a[520], a[521]};
    assign c[601:600] = a[917:916];
    assign c[603:602] = a[597:596];
    assign c[605:604] = a[993:992];
    assign c[607:606] = a[919:918];
    assign c[609:608] = a[599:598];
    assign c[611:610] = a[995:994];
    assign c[613:612] = a[921:920];
    assign c[615:614] = a[601:600];
    assign c[617:616] = a[997:996];
    assign c[619:618] = {a[1168], a[1169]};
    assign c[621:620] = a[849:848];
    assign c[623:622] = {a[528], a[529]};
    assign c[625:624] = a[209:208];
    assign c[627:626] = a[851:850];
    assign c[629:628] = {a[530], a[531]};
    assign c[631:630] = a[211:210];
    assign c[633:632] = a[853:852];
    assign c[635:634] = {a[532], a[533]};
    assign c[637:636] = a[929:928];
    assign c[639:638] = a[609:608];
    assign c[641:640] = {a[534], a[535]};
    assign c[643:642] = a[931:930];
    assign c[645:644] = a[611:610];
    assign c[647:646] = {a[536], a[537]};
    assign c[649:648] = a[933:932];
    assign c[651:650] = a[613:612];
    assign c[653:652] = a[1009:1008];
    assign c[655:654] = a[935:934];
    assign c[657:656] = a[615:614];
    assign c[659:658] = a[1011:1010];
    assign c[661:660] = a[937:936];
    assign c[663:662] = a[617:616];
    assign c[665:664] = a[1013:1012];
    assign c[667:666] = {a[1184], a[1185]};
    assign c[669:668] = a[865:864];
    assign c[671:670] = {a[544], a[545]};
    assign c[673:672] = a[225:224];
    assign c[675:674] = a[867:866];
    assign c[677:676] = {a[546], a[547]};
    assign c[679:678] = a[227:226];
    assign c[681:680] = a[869:868];
    assign c[683:682] = {a[548], a[549]};
    assign c[685:684] = a[945:944];
    assign c[687:686] = a[625:624];
    assign c[689:688] = {a[550], a[551]};
    assign c[691:690] = a[947:946];
    assign c[693:692] = a[627:626];
    assign c[695:694] = {a[552], a[553]};
    assign c[697:696] = a[949:948];
    assign c[699:698] = a[629:628];
    assign c[701:700] = a[1025:1024];
    assign c[703:702] = a[951:950];
    assign c[705:704] = a[631:630];
    assign c[707:706] = a[1027:1026];
    assign c[709:708] = a[953:952];
    assign c[711:710] = a[633:632];
    assign c[713:712] = a[1029:1028];
    assign c[715:714] = a[955:954];
    assign c[717:716] = a[881:880];
    assign c[719:718] = {a[560], a[561]};
    assign c[721:720] = a[241:240];
    assign c[723:722] = a[883:882];
    assign c[725:724] = {a[562], a[563]};
    assign c[727:726] = a[243:242];
    assign c[729:728] = a[885:884];
    assign c[731:730] = {a[564], a[565]};
    assign c[733:732] = a[961:960];
    assign c[735:734] = a[641:640];
    assign c[737:736] = {a[566], a[567]};
    assign c[739:738] = a[963:962];
    assign c[741:740] = a[643:642];
    assign c[743:742] = {a[568], a[569]};
    assign c[745:744] = a[965:964];
    assign c[747:746] = a[645:644];
    assign c[749:748] = a[1041:1040];
    assign c[751:750] = a[967:966];
    assign c[753:752] = a[647:646];
    assign c[755:754] = a[1043:1042];
    assign c[757:756] = a[969:968];
    assign c[759:758] = a[649:648];
    assign c[761:760] = a[1045:1044];
    assign c[763:762] = a[971:970];
    assign c[765:764] = a[897:896];
    assign c[767:766] = {a[576], a[577]};
    assign c[769:768] = a[257:256];
    assign c[771:770] = a[899:898];
    assign c[773:772] = {a[578], a[579]};
    assign c[775:774] = a[259:258];
    assign c[777:776] = a[901:900];
    assign c[779:778] = {a[580], a[581]};
    assign c[781:780] = a[977:976];
    assign c[783:782] = a[657:656];
    assign c[785:784] = {a[582], a[583]};
    assign c[787:786] = a[979:978];
    assign c[789:788] = a[659:658];
    assign c[791:790] = {a[584], a[585]};
    assign c[793:792] = a[981:980];
    assign c[795:794] = a[661:660];
    assign c[797:796] = a[1057:1056];
    assign c[799:798] = a[983:982];
    assign c[801:800] = a[663:662];
    assign c[803:802] = a[1059:1058];
    assign c[805:804] = a[985:984];
    assign c[807:806] = a[665:664];
    assign c[809:808] = a[1061:1060];
    assign c[811:810] = a[987:986];
    assign c[813:812] = a[913:912];
    assign c[815:814] = {a[592], a[593]};
    assign c[817:816] = a[273:272];
    assign c[819:818] = a[915:914];
    assign c[821:820] = {a[594], a[595]};
    assign c[823:822] = a[275:274];
    assign c[825:824] = a[917:916];
    assign c[827:826] = {a[596], a[597]};
    assign c[829:828] = a[993:992];
    assign c[831:830] = a[673:672];
    assign c[833:832] = {a[598], a[599]};
    assign c[835:834] = a[995:994];
    assign c[837:836] = a[675:674];
    assign c[839:838] = {a[600], a[601]};
    assign c[841:840] = a[997:996];
    assign c[843:842] = a[677:676];
    assign c[845:844] = a[1073:1072];
    assign c[847:846] = a[999:998];
    assign c[849:848] = a[679:678];
    assign c[851:850] = a[1075:1074];
    assign c[853:852] = a[1001:1000];
    assign c[855:854] = a[681:680];
    assign c[857:856] = a[1077:1076];
    assign c[859:858] = a[1003:1002];
    assign c[861:860] = a[929:928];
    assign c[863:862] = {a[608], a[609]};
    assign c[865:864] = a[289:288];
    assign c[867:866] = a[931:930];
    assign c[869:868] = {a[610], a[611]};
    assign c[871:870] = a[291:290];
    assign c[873:872] = a[933:932];
    assign c[875:874] = {a[612], a[613]};
    assign c[877:876] = a[1009:1008];
    assign c[879:878] = a[689:688];
    assign c[881:880] = {a[614], a[615]};
    assign c[883:882] = a[1011:1010];
    assign c[885:884] = a[691:690];
    assign c[887:886] = {a[616], a[617]};
    assign c[889:888] = a[1013:1012];
    assign c[891:890] = a[693:692];
    assign c[893:892] = a[1089:1088];
    assign c[895:894] = a[1015:1014];
    assign c[897:896] = a[695:694];
    assign c[899:898] = a[1091:1090];
    assign c[901:900] = a[1017:1016];
    assign c[903:902] = a[697:696];
    assign c[905:904] = a[1093:1092];
    assign c[907:906] = a[1019:1018];
    assign c[909:908] = a[945:944];
    assign c[911:910] = {a[624], a[625]};
    assign c[913:912] = a[305:304];
    assign c[915:914] = a[947:946];
    assign c[917:916] = {a[626], a[627]};
    assign c[919:918] = a[307:306];
    assign c[921:920] = a[949:948];
    assign c[923:922] = {a[628], a[629]};
    assign c[925:924] = a[1025:1024];
    assign c[927:926] = a[705:704];
    assign c[929:928] = {a[630], a[631]};
    assign c[931:930] = a[1027:1026];
    assign c[933:932] = a[707:706];
    assign c[935:934] = {a[632], a[633]};
    assign c[937:936] = a[1029:1028];
    assign c[939:938] = a[709:708];
    assign c[941:940] = a[1105:1104];
    assign c[943:942] = a[1031:1030];
    assign c[945:944] = a[711:710];
    assign c[947:946] = a[1107:1106];
    assign c[949:948] = a[1033:1032];
    assign c[951:950] = a[713:712];
    assign c[953:952] = a[1109:1108];
    assign c[955:954] = a[1035:1034];
    assign c[957:956] = a[961:960];
    assign c[959:958] = {a[640], a[641]};
    assign c[961:960] = a[321:320];
    assign c[963:962] = a[963:962];
    assign c[965:964] = {a[642], a[643]};
    assign c[967:966] = a[323:322];
    assign c[969:968] = a[965:964];
    assign c[971:970] = {a[644], a[645]};
    assign c[973:972] = a[1041:1040];
    assign c[975:974] = a[721:720];
    assign c[977:976] = {a[646], a[647]};
    assign c[979:978] = a[1043:1042];
    assign c[981:980] = a[723:722];
    assign c[983:982] = {a[648], a[649]};
    assign c[985:984] = a[1045:1044];
    assign c[987:986] = a[725:724];
    assign c[989:988] = a[1121:1120];
    assign c[991:990] = a[1047:1046];
    assign c[993:992] = a[727:726];
    assign c[995:994] = a[1123:1122];
    assign c[997:996] = a[1049:1048];
    assign c[999:998] = a[729:728];
    assign c[1001:1000] = a[1125:1124];
    assign c[1003:1002] = a[1051:1050];
    assign c[1005:1004] = a[977:976];
    assign c[1007:1006] = {a[656], a[657]};
    assign c[1009:1008] = a[337:336];
    assign c[1011:1010] = a[979:978];
    assign c[1013:1012] = {a[658], a[659]};
    assign c[1015:1014] = a[339:338];
    assign c[1017:1016] = a[981:980];
    assign c[1019:1018] = {a[660], a[661]};
    assign c[1021:1020] = a[1057:1056];
    assign c[1023:1022] = a[737:736];
    assign c[1025:1024] = {a[662], a[663]};
    assign c[1027:1026] = a[1059:1058];
    assign c[1029:1028] = a[739:738];
    assign c[1031:1030] = {a[664], a[665]};
    assign c[1033:1032] = a[1061:1060];
    assign c[1035:1034] = a[741:740];
    assign c[1037:1036] = a[1137:1136];
    assign c[1039:1038] = a[1063:1062];
    assign c[1041:1040] = a[743:742];
    assign c[1043:1042] = a[1139:1138];
    assign c[1045:1044] = a[1065:1064];
    assign c[1047:1046] = a[745:744];
    assign c[1049:1048] = a[1141:1140];
    assign c[1051:1050] = a[1067:1066];
    assign c[1053:1052] = a[993:992];
    assign c[1055:1054] = {a[672], a[673]};
    assign c[1057:1056] = a[353:352];
    assign c[1059:1058] = a[995:994];
    assign c[1061:1060] = {a[674], a[675]};
    assign c[1063:1062] = a[355:354];
    assign c[1065:1064] = a[997:996];
    assign c[1067:1066] = {a[676], a[677]};
    assign c[1069:1068] = a[1073:1072];
    assign c[1071:1070] = a[753:752];
    assign c[1073:1072] = {a[678], a[679]};
    assign c[1075:1074] = a[1075:1074];
    assign c[1077:1076] = a[755:754];
    assign c[1079:1078] = {a[680], a[681]};
    assign c[1081:1080] = a[1077:1076];
    assign c[1083:1082] = a[757:756];
    assign c[1085:1084] = a[1153:1152];
    assign c[1087:1086] = a[1079:1078];
    assign c[1089:1088] = a[759:758];
    assign c[1091:1090] = a[1155:1154];
    assign c[1093:1092] = a[1081:1080];
    assign c[1095:1094] = a[761:760];
    assign c[1097:1096] = a[1157:1156];
    assign c[1099:1098] = a[1083:1082];
    assign c[1101:1100] = a[1009:1008];
    assign c[1103:1102] = {a[688], a[689]};
    assign c[1105:1104] = a[369:368];
    assign c[1107:1106] = a[1011:1010];
    assign c[1109:1108] = {a[690], a[691]};
    assign c[1111:1110] = a[371:370];
    assign c[1113:1112] = a[1013:1012];
    assign c[1115:1114] = {a[692], a[693]};
    assign c[1117:1116] = a[1089:1088];
    assign c[1119:1118] = a[769:768];
    assign c[1121:1120] = {a[694], a[695]};
    assign c[1123:1122] = a[1091:1090];
    assign c[1125:1124] = a[771:770];
    assign c[1127:1126] = {a[696], a[697]};
    assign c[1129:1128] = a[1093:1092];
    assign c[1131:1130] = a[773:772];
    assign c[1133:1132] = a[1169:1168];
    assign c[1135:1134] = a[1095:1094];
    assign c[1137:1136] = a[775:774];
    assign c[1139:1138] = a[1171:1170];
    assign c[1141:1140] = a[1097:1096];
    assign c[1143:1142] = a[777:776];
    assign c[1145:1144] = a[1173:1172];
    assign c[1147:1146] = a[1099:1098];
    assign c[1149:1148] = a[1025:1024];
    assign c[1151:1150] = {a[704], a[705]};
    assign c[1153:1152] = a[385:384];
    assign c[1155:1154] = a[1027:1026];
    assign c[1157:1156] = {a[706], a[707]};
    assign c[1159:1158] = a[387:386];
    assign c[1161:1160] = a[1029:1028];
    assign c[1163:1162] = {a[708], a[709]};
    assign c[1165:1164] = a[1105:1104];
    assign c[1167:1166] = a[785:784];
    assign c[1169:1168] = {a[710], a[711]};
    assign c[1171:1170] = a[1107:1106];
    assign c[1173:1172] = a[787:786];
    assign c[1175:1174] = {a[712], a[713]};
    assign c[1177:1176] = a[1109:1108];
    assign c[1179:1178] = a[789:788];
    assign c[1181:1180] = a[1185:1184];
    assign c[1183:1182] = a[1111:1110];
    assign c[1185:1184] = a[791:790];
endmodule
/* c == v1(a) */
module v1(a, c);
    input [1185:0] a;
    output [1185:0] c;
    assign c[1:0] = {a[716], a[717]};
    assign c[3:2] = a[397:396];
    assign c[5:4] = a[1039:1038];
    assign c[7:6] = {a[718], a[719]};
    assign c[9:8] = a[399:398];
    assign c[11:10] = a[795:794];
    assign c[13:12] = a[5:4];
    assign c[15:14] = a[1117:1116];
    assign c[17:16] = a[797:796];
    assign c[19:18] = a[7:6];
    assign c[21:20] = a[1119:1118];
    assign c[23:22] = a[799:798];
    assign c[25:24] = a[9:8];
    assign c[27:26] = a[405:404];
    assign c[29:28] = a[1047:1046];
    assign c[31:30] = a[11:10];
    assign c[33:32] = a[407:406];
    assign c[35:34] = a[1049:1048];
    assign c[37:36] = a[13:12];
    assign c[39:38] = a[409:408];
    assign c[41:40] = a[1051:1050];
    assign c[43:42] = a[15:14];
    assign c[45:44] = a[411:410];
    assign c[47:46] = a[1053:1052];
    assign c[49:48] = {a[732], a[733]};
    assign c[51:50] = a[413:412];
    assign c[53:52] = a[1055:1054];
    assign c[55:54] = {a[734], a[735]};
    assign c[57:56] = a[415:414];
    assign c[59:58] = a[811:810];
    assign c[61:60] = a[21:20];
    assign c[63:62] = a[1133:1132];
    assign c[65:64] = a[813:812];
    assign c[67:66] = a[23:22];
    assign c[69:68] = a[1135:1134];
    assign c[71:70] = a[815:814];
    assign c[73:72] = a[25:24];
    assign c[75:74] = a[421:420];
    assign c[77:76] = a[1063:1062];
    assign c[79:78] = a[27:26];
    assign c[81:80] = a[423:422];
    assign c[83:82] = a[1065:1064];
    assign c[85:84] = a[29:28];
    assign c[87:86] = a[425:424];
    assign c[89:88] = a[1067:1066];
    assign c[91:90] = a[31:30];
    assign c[93:92] = a[427:426];
    assign c[95:94] = a[1069:1068];
    assign c[97:96] = {a[748], a[749]};
    assign c[99:98] = a[429:428];
    assign c[101:100] = a[1071:1070];
    assign c[103:102] = {a[750], a[751]};
    assign c[105:104] = a[431:430];
    assign c[107:106] = a[827:826];
    assign c[109:108] = a[37:36];
    assign c[111:110] = a[1149:1148];
    assign c[113:112] = a[829:828];
    assign c[115:114] = a[39:38];
    assign c[117:116] = a[1151:1150];
    assign c[119:118] = a[831:830];
    assign c[121:120] = a[41:40];
    assign c[123:122] = a[437:436];
    assign c[125:124] = a[1079:1078];
    assign c[127:126] = a[43:42];
    assign c[129:128] = a[439:438];
    assign c[131:130] = a[1081:1080];
    assign c[133:132] = a[45:44];
    assign c[135:134] = a[441:440];
    assign c[137:136] = a[1083:1082];
    assign c[139:138] = a[47:46];
    assign c[141:140] = a[443:442];
    assign c[143:142] = a[1085:1084];
    assign c[145:144] = {a[764], a[765]};
    assign c[147:146] = a[445:444];
    assign c[149:148] = a[1087:1086];
    assign c[151:150] = {a[766], a[767]};
    assign c[153:152] = a[447:446];
    assign c[155:154] = a[843:842];
    assign c[157:156] = a[53:52];
    assign c[159:158] = a[1165:1164];
    assign c[161:160] = a[845:844];
    assign c[163:162] = a[55:54];
    assign c[165:164] = a[1167:1166];
    assign c[167:166] = a[847:846];
    assign c[169:168] = a[57:56];
    assign c[171:170] = a[453:452];
    assign c[173:172] = a[1095:1094];
    assign c[175:174] = a[59:58];
    assign c[177:176] = a[455:454];
    assign c[179:178] = a[1097:1096];
    assign c[181:180] = a[61:60];
    assign c[183:182] = a[457:456];
    assign c[185:184] = a[1099:1098];
    assign c[187:186] = a[63:62];
    assign c[189:188] = a[459:458];
    assign c[191:190] = a[1101:1100];
    assign c[193:192] = {a[780], a[781]};
    assign c[195:194] = a[461:460];
    assign c[197:196] = a[1103:1102];
    assign c[199:198] = {a[782], a[783]};
    assign c[201:200] = a[463:462];
    assign c[203:202] = a[859:858];
    assign c[205:204] = a[69:68];
    assign c[207:206] = a[1181:1180];
    assign c[209:208] = a[861:860];
    assign c[211:210] = a[71:70];
    assign c[213:212] = a[1183:1182];
    assign c[215:214] = a[863:862];
    assign c[217:216] = a[73:72];
    assign c[219:218] = a[469:468];
    assign c[221:220] = a[1111:1110];
    assign c[223:222] = a[75:74];
    assign c[225:224] = a[717:716];
    assign c[227:226] = {a[396], a[397]};
    assign c[229:228] = a[77:76];
    assign c[231:230] = a[719:718];
    assign c[233:232] = {a[398], a[399]};
    assign c[235:234] = a[795:794];
    assign c[237:236] = a[475:474];
    assign c[239:238] = a[871:870];
    assign c[241:240] = {a[1042], a[1043]};
    assign c[243:242] = a[477:476];
    assign c[245:244] = a[873:872];
    assign c[247:246] = {a[1044], a[1045]};
    assign c[249:248] = a[479:478];
    assign c[251:250] = a[875:874];
    assign c[253:252] = a[85:84];
    assign c[255:254] = a[727:726];
    assign c[257:256] = a[877:876];
    assign c[259:258] = a[87:86];
    assign c[261:260] = a[729:728];
    assign c[263:262] = a[879:878];
    assign c[265:264] = a[89:88];
    assign c[267:266] = a[731:730];
    assign c[269:268] = {a[410], a[411]};
    assign c[271:270] = a[91:90];
    assign c[273:272] = a[733:732];
    assign c[275:274] = {a[412], a[413]};
    assign c[277:276] = a[93:92];
    assign c[279:278] = a[735:734];
    assign c[281:280] = {a[414], a[415]};
    assign c[283:282] = a[811:810];
    assign c[285:284] = a[491:490];
    assign c[287:286] = a[887:886];
    assign c[289:288] = {a[1058], a[1059]};
    assign c[291:290] = a[493:492];
    assign c[293:292] = a[889:888];
    assign c[295:294] = {a[1060], a[1061]};
    assign c[297:296] = a[495:494];
    assign c[299:298] = a[891:890];
    assign c[301:300] = a[101:100];
    assign c[303:302] = a[743:742];
    assign c[305:304] = a[893:892];
    assign c[307:306] = a[103:102];
    assign c[309:308] = a[745:744];
    assign c[311:310] = a[895:894];
    assign c[313:312] = a[105:104];
    assign c[315:314] = a[747:746];
    assign c[317:316] = {a[426], a[427]};
    assign c[319:318] = a[107:106];
    assign c[321:320] = a[749:748];
    assign c[323:322] = {a[428], a[429]};
    assign c[325:324] = a[109:108];
    assign c[327:326] = a[751:750];
    assign c[329:328] = {a[430], a[431]};
    assign c[331:330] = a[827:826];
    assign c[333:332] = a[507:506];
    assign c[335:334] = a[903:902];
    assign c[337:336] = {a[1074], a[1075]};
    assign c[339:338] = a[509:508];
    assign c[341:340] = a[905:904];
    assign c[343:342] = {a[1076], a[1077]};
    assign c[345:344] = a[511:510];
    assign c[347:346] = a[907:906];
    assign c[349:348] = a[117:116];
    assign c[351:350] = a[759:758];
    assign c[353:352] = a[909:908];
    assign c[355:354] = a[119:118];
    assign c[357:356] = a[761:760];
    assign c[359:358] = a[911:910];
    assign c[361:360] = a[121:120];
    assign c[363:362] = a[763:762];
    assign c[365:364] = {a[442], a[443]};
    assign c[367:366] = a[123:122];
    assign c[369:368] = a[765:764];
    assign c[371:370] = {a[444], a[445]};
    assign c[373:372] = a[125:124];
    assign c[375:374] = a[767:766];
    assign c[377:376] = {a[446], a[447]};
    assign c[379:378] = a[843:842];
    assign c[381:380] = a[523:522];
    assign c[383:382] = a[919:918];
    assign c[385:384] = {a[1090], a[1091]};
    assign c[387:386] = a[525:524];
    assign c[389:388] = a[921:920];
    assign c[391:390] = {a[1092], a[1093]};
    assign c[393:392] = a[527:526];
    assign c[395:394] = a[923:922];
    assign c[397:396] = a[133:132];
    assign c[399:398] = a[775:774];
    assign c[401:400] = a[925:924];
    assign c[403:402] = a[135:134];
    assign c[405:404] = a[777:776];
    assign c[407:406] = a[927:926];
    assign c[409:408] = a[137:136];
    assign c[411:410] = a[779:778];
    assign c[413:412] = {a[458], a[459]};
    assign c[415:414] = a[139:138];
    assign c[417:416] = a[781:780];
    assign c[419:418] = {a[460], a[461]};
    assign c[421:420] = a[141:140];
    assign c[423:422] = a[783:782];
    assign c[425:424] = {a[462], a[463]};
    assign c[427:426] = a[859:858];
    assign c[429:428] = a[539:538];
    assign c[431:430] = a[935:934];
    assign c[433:432] = {a[1106], a[1107]};
    assign c[435:434] = a[541:540];
    assign c[437:436] = a[937:936];
    assign c[439:438] = {a[1108], a[1109]};
    assign c[441:440] = a[543:542];
    assign c[443:442] = a[939:938];
    assign c[445:444] = a[149:148];
    assign c[447:446] = a[791:790];
    assign c[449:448] = a[941:940];
    assign c[451:450] = a[151:150];
    assign c[453:452] = a[793:792];
    assign c[455:454] = a[943:942];
    assign c[457:456] = a[153:152];
    assign c[459:458] = a[795:794];
    assign c[461:460] = {a[474], a[475]};
    assign c[463:462] = a[155:154];
    assign c[465:464] = a[797:796];
    assign c[467:466] = {a[476], a[477]};
    assign c[469:468] = a[157:156];
    assign c[471:470] = a[799:798];
    assign c[473:472] = {a[478], a[479]};
    assign c[475:474] = a[875:874];
    assign c[477:476] = a[555:554];
    assign c[479:478] = a[951:950];
    assign c[481:480] = {a[1122], a[1123]};
    assign c[483:482] = a[557:556];
    assign c[485:484] = a[953:952];
    assign c[487:486] = {a[1124], a[1125]};
    assign c[489:488] = a[559:558];
    assign c[491:490] = a[955:954];
    assign c[493:492] = a[165:164];
    assign c[495:494] = a[807:806];
    assign c[497:496] = a[957:956];
    assign c[499:498] = a[167:166];
    assign c[501:500] = a[809:808];
    assign c[503:502] = a[959:958];
    assign c[505:504] = a[169:168];
    assign c[507:506] = a[811:810];
    assign c[509:508] = {a[490], a[491]};
    assign c[511:510] = a[171:170];
    assign c[513:512] = a[813:812];
    assign c[515:514] = {a[492], a[493]};
    assign c[517:516] = a[173:172];
    assign c[519:518] = a[815:814];
    assign c[521:520] = {a[494], a[495]};
    assign c[523:522] = a[891:890];
    assign c[525:524] = a[571:570];
    assign c[527:526] = a[967:966];
    assign c[529:528] = {a[1138], a[1139]};
    assign c[531:530] = a[573:572];
    assign c[533:532] = a[969:968];
    assign c[535:534] = {a[1140], a[1141]};
    assign c[537:536] = a[575:574];
    assign c[539:538] = a[971:970];
    assign c[541:540] = a[181:180];
    assign c[543:542] = a[823:822];
    assign c[545:544] = a[973:972];
    assign c[547:546] = a[183:182];
    assign c[549:548] = a[825:824];
    assign c[551:550] = a[975:974];
    assign c[553:552] = a[185:184];
    assign c[555:554] = a[827:826];
    assign c[557:556] = {a[506], a[507]};
    assign c[559:558] = a[187:186];
    assign c[561:560] = a[829:828];
    assign c[563:562] = {a[508], a[509]};
    assign c[565:564] = a[189:188];
    assign c[567:566] = a[831:830];
    assign c[569:568] = {a[510], a[511]};
    assign c[571:570] = a[907:906];
    assign c[573:572] = a[587:586];
    assign c[575:574] = a[983:982];
    assign c[577:576] = {a[1154], a[1155]};
    assign c[579:578] = a[589:588];
    assign c[581:580] = a[985:984];
    assign c[583:582] = {a[1156], a[1157]};
    assign c[585:584] = a[591:590];
    assign c[587:586] = a[987:986];
    assign c[589:588] = a[197:196];
    assign c[591:590] = a[839:838];
    assign c[593:592] = a[989:988];
    assign c[595:594] = a[199:198];
    assign c[597:596] = a[841:840];
    assign c[599:598] = a[991:990];
    assign c[601:600] = a[201:200];
    assign c[603:602] = a[843:842];
    assign c[605:604] = {a[522], a[523]};
    assign c[607:606] = a[203:202];
    assign c[609:608] = a[845:844];
    assign c[611:610] = {a[524], a[525]};
    assign c[613:612] = a[205:204];
    assign c[615:614] = a[847:846];
    assign c[617:616] = {a[526], a[527]};
    assign c[619:618] = a[923:922];
    assign c[621:620] = a[603:602];
    assign c[623:622] = a[999:998];
    assign c[625:624] = {a[1170], a[1171]};
    assign c[627:626] = a[605:604];
    assign c[629:628] = a[1001:1000];
    assign c[631:630] = {a[1172], a[1173]};
    assign c[633:632] = a[607:606];
    assign c[635:634] = a[1003:1002];
    assign c[637:636] = a[213:212];
    assign c[639:638] = a[855:854];
    assign c[641:640] = a[1005:1004];
    assign c[643:642] = a[215:214];
    assign c[645:644] = a[857:856];
    assign c[647:646] = a[1007:1006];
    assign c[649:648] = a[217:216];
    assign c[651:650] = a[859:858];
    assign c[653:652] = {a[538], a[539]};
    assign c[655:654] = a[219:218];
    assign c[657:656] = a[861:860];
    assign c[659:658] = {a[540], a[541]};
    assign c[661:660] = a[221:220];
    assign c[663:662] = a[863:862];
    assign c[665:664] = {a[542], a[543]};
    assign c[667:666] = a[939:938];
    assign c[669:668] = a[619:618];
    assign c[671:670] = a[1015:1014];
    assign c[673:672] = a[941:940];
    assign c[675:674] = a[621:620];
    assign c[677:676] = a[1017:1016];
    assign c[679:678] = a[943:942];
    assign c[681:680] = a[623:622];
    assign c[683:682] = a[1019:1018];
    assign c[685:684] = a[229:228];
    assign c[687:686] = a[871:870];
    assign c[689:688] = a[1021:1020];
    assign c[691:690] = a[231:230];
    assign c[693:692] = a[873:872];
    assign c[695:694] = a[1023:1022];
    assign c[697:696] = a[233:232];
    assign c[699:698] = a[875:874];
    assign c[701:700] = {a[554], a[555]};
    assign c[703:702] = a[235:234];
    assign c[705:704] = a[877:876];
    assign c[707:706] = {a[556], a[557]};
    assign c[709:708] = a[237:236];
    assign c[711:710] = a[879:878];
    assign c[713:712] = {a[558], a[559]};
    assign c[715:714] = a[239:238];
    assign c[717:716] = a[635:634];
    assign c[719:718] = a[1031:1030];
    assign c[721:720] = a[957:956];
    assign c[723:722] = a[637:636];
    assign c[725:724] = a[1033:1032];
    assign c[727:726] = a[959:958];
    assign c[729:728] = a[639:638];
    assign c[731:730] = a[1035:1034];
    assign c[733:732] = a[245:244];
    assign c[735:734] = a[887:886];
    assign c[737:736] = a[1037:1036];
    assign c[739:738] = a[247:246];
    assign c[741:740] = a[889:888];
    assign c[743:742] = a[1039:1038];
    assign c[745:744] = a[249:248];
    assign c[747:746] = a[891:890];
    assign c[749:748] = {a[570], a[571]};
    assign c[751:750] = a[251:250];
    assign c[753:752] = a[893:892];
    assign c[755:754] = {a[572], a[573]};
    assign c[757:756] = a[253:252];
    assign c[759:758] = a[895:894];
    assign c[761:760] = {a[574], a[575]};
    assign c[763:762] = a[255:254];
    assign c[765:764] = a[651:650];
    assign c[767:766] = a[1047:1046];
    assign c[769:768] = a[973:972];
    assign c[771:770] = a[653:652];
    assign c[773:772] = a[1049:1048];
    assign c[775:774] = a[975:974];
    assign c[777:776] = a[655:654];
    assign c[779:778] = a[1051:1050];
    assign c[781:780] = a[261:260];
    assign c[783:782] = a[903:902];
    assign c[785:784] = a[1053:1052];
    assign c[787:786] = a[263:262];
    assign c[789:788] = a[905:904];
    assign c[791:790] = a[1055:1054];
    assign c[793:792] = a[265:264];
    assign c[795:794] = a[907:906];
    assign c[797:796] = {a[586], a[587]};
    assign c[799:798] = a[267:266];
    assign c[801:800] = a[909:908];
    assign c[803:802] = {a[588], a[589]};
    assign c[805:804] = a[269:268];
    assign c[807:806] = a[911:910];
    assign c[809:808] = {a[590], a[591]};
    assign c[811:810] = a[271:270];
    assign c[813:812] = a[667:666];
    assign c[815:814] = a[1063:1062];
    assign c[817:816] = a[989:988];
    assign c[819:818] = a[669:668];
    assign c[821:820] = a[1065:1064];
    assign c[823:822] = a[991:990];
    assign c[825:824] = a[671:670];
    assign c[827:826] = a[1067:1066];
    assign c[829:828] = a[277:276];
    assign c[831:830] = a[919:918];
    assign c[833:832] = a[1069:1068];
    assign c[835:834] = a[279:278];
    assign c[837:836] = a[921:920];
    assign c[839:838] = a[1071:1070];
    assign c[841:840] = a[281:280];
    assign c[843:842] = a[923:922];
    assign c[845:844] = {a[602], a[603]};
    assign c[847:846] = a[283:282];
    assign c[849:848] = a[925:924];
    assign c[851:850] = {a[604], a[605]};
    assign c[853:852] = a[285:284];
    assign c[855:854] = a[927:926];
    assign c[857:856] = {a[606], a[607]};
    assign c[859:858] = a[287:286];
    assign c[861:860] = a[683:682];
    assign c[863:862] = a[1079:1078];
    assign c[865:864] = a[1005:1004];
    assign c[867:866] = a[685:684];
    assign c[869:868] = a[1081:1080];
    assign c[871:870] = a[1007:1006];
    assign c[873:872] = a[687:686];
    assign c[875:874] = a[1083:1082];
    assign c[877:876] = a[293:292];
    assign c[879:878] = a[935:934];
    assign c[881:880] = a[1085:1084];
    assign c[883:882] = a[295:294];
    assign c[885:884] = a[937:936];
    assign c[887:886] = a[1087:1086];
    assign c[889:888] = a[297:296];
    assign c[891:890] = a[939:938];
    assign c[893:892] = {a[618], a[619]};
    assign c[895:894] = a[299:298];
    assign c[897:896] = a[941:940];
    assign c[899:898] = {a[620], a[621]};
    assign c[901:900] = a[301:300];
    assign c[903:902] = a[943:942];
    assign c[905:904] = {a[622], a[623]};
    assign c[907:906] = a[303:302];
    assign c[909:908] = a[699:698];
    assign c[911:910] = a[1095:1094];
    assign c[913:912] = a[1021:1020];
    assign c[915:914] = a[701:700];
    assign c[917:916] = a[1097:1096];
    assign c[919:918] = a[1023:1022];
    assign c[921:920] = a[703:702];
    assign c[923:922] = a[1099:1098];
    assign c[925:924] = a[309:308];
    assign c[927:926] = a[951:950];
    assign c[929:928] = a[1101:1100];
    assign c[931:930] = a[311:310];
    assign c[933:932] = a[953:952];
    assign c[935:934] = a[1103:1102];
    assign c[937:936] = a[313:312];
    assign c[939:938] = a[955:954];
    assign c[941:940] = {a[634], a[635]};
    assign c[943:942] = a[315:314];
    assign c[945:944] = a[957:956];
    assign c[947:946] = {a[636], a[637]};
    assign c[949:948] = a[317:316];
    assign c[951:950] = a[959:958];
    assign c[953:952] = {a[638], a[639]};
    assign c[955:954] = a[319:318];
    assign c[957:956] = a[715:714];
    assign c[959:958] = a[1111:1110];
    assign c[961:960] = a[1037:1036];
    assign c[963:962] = a[717:716];
    assign c[965:964] = a[1113:1112];
    assign c[967:966] = a[1039:1038];
    assign c[969:968] = a[719:718];
    assign c[971:970] = a[1115:1114];
    assign c[973:972] = a[325:324];
    assign c[975:974] = a[967:966];
    assign c[977:976] = a[1117:1116];
    assign c[979:978] = a[327:326];
    assign c[981:980] = a[969:968];
    assign c[983:982] = a[1119:1118];
    assign c[985:984] = a[329:328];
    assign c[987:986] = a[971:970];
    assign c[989:988] = {a[650], a[651]};
    assign c[991:990] = a[331:330];
    assign c[993:992] = a[973:972];
    assign c[995:994] = {a[652], a[653]};
    assign c[997:996] = a[333:332];
    assign c[999:998] = a[975:974];
    assign c[1001:1000] = {a[654], a[655]};
    assign c[1003:1002] = a[335:334];
    assign c[1005:1004] = a[731:730];
    assign c[1007:1006] = a[1127:1126];
    assign c[1009:1008] = a[1053:1052];
    assign c[1011:1010] = a[733:732];
    assign c[1013:1012] = a[1129:1128];
    assign c[1015:1014] = a[1055:1054];
    assign c[1017:1016] = a[735:734];
    assign c[1019:1018] = a[1131:1130];
    assign c[1021:1020] = a[341:340];
    assign c[1023:1022] = a[983:982];
    assign c[1025:1024] = a[1133:1132];
    assign c[1027:1026] = a[343:342];
    assign c[1029:1028] = a[985:984];
    assign c[1031:1030] = a[1135:1134];
    assign c[1033:1032] = a[345:344];
    assign c[1035:1034] = a[987:986];
    assign c[1037:1036] = {a[666], a[667]};
    assign c[1039:1038] = a[347:346];
    assign c[1041:1040] = a[989:988];
    assign c[1043:1042] = {a[668], a[669]};
    assign c[1045:1044] = a[349:348];
    assign c[1047:1046] = a[991:990];
    assign c[1049:1048] = {a[670], a[671]};
    assign c[1051:1050] = a[351:350];
    assign c[1053:1052] = a[747:746];
    assign c[1055:1054] = a[1143:1142];
    assign c[1057:1056] = a[1069:1068];
    assign c[1059:1058] = a[749:748];
    assign c[1061:1060] = a[1145:1144];
    assign c[1063:1062] = a[1071:1070];
    assign c[1065:1064] = a[751:750];
    assign c[1067:1066] = a[1147:1146];
    assign c[1069:1068] = a[357:356];
    assign c[1071:1070] = a[999:998];
    assign c[1073:1072] = a[1149:1148];
    assign c[1075:1074] = a[359:358];
    assign c[1077:1076] = a[1001:1000];
    assign c[1079:1078] = a[1151:1150];
    assign c[1081:1080] = a[361:360];
    assign c[1083:1082] = a[1003:1002];
    assign c[1085:1084] = {a[682], a[683]};
    assign c[1087:1086] = a[363:362];
    assign c[1089:1088] = a[1005:1004];
    assign c[1091:1090] = {a[684], a[685]};
    assign c[1093:1092] = a[365:364];
    assign c[1095:1094] = a[1007:1006];
    assign c[1097:1096] = {a[686], a[687]};
    assign c[1099:1098] = a[367:366];
    assign c[1101:1100] = a[763:762];
    assign c[1103:1102] = a[1159:1158];
    assign c[1105:1104] = a[1085:1084];
    assign c[1107:1106] = a[765:764];
    assign c[1109:1108] = a[1161:1160];
    assign c[1111:1110] = a[1087:1086];
    assign c[1113:1112] = a[767:766];
    assign c[1115:1114] = a[1163:1162];
    assign c[1117:1116] = a[373:372];
    assign c[1119:1118] = a[1015:1014];
    assign c[1121:1120] = a[1165:1164];
    assign c[1123:1122] = a[375:374];
    assign c[1125:1124] = a[1017:1016];
    assign c[1127:1126] = a[1167:1166];
    assign c[1129:1128] = a[377:376];
    assign c[1131:1130] = a[1019:1018];
    assign c[1133:1132] = {a[698], a[699]};
    assign c[1135:1134] = a[379:378];
    assign c[1137:1136] = a[1021:1020];
    assign c[1139:1138] = {a[700], a[701]};
    assign c[1141:1140] = a[381:380];
    assign c[1143:1142] = a[1023:1022];
    assign c[1145:1144] = {a[702], a[703]};
    assign c[1147:1146] = a[383:382];
    assign c[1149:1148] = a[779:778];
    assign c[1151:1150] = a[1175:1174];
    assign c[1153:1152] = a[1101:1100];
    assign c[1155:1154] = a[781:780];
    assign c[1157:1156] = a[1177:1176];
    assign c[1159:1158] = a[1103:1102];
    assign c[1161:1160] = a[783:782];
    assign c[1163:1162] = a[1179:1178];
    assign c[1165:1164] = a[389:388];
    assign c[1167:1166] = a[1031:1030];
    assign c[1169:1168] = a[1181:1180];
    assign c[1171:1170] = a[391:390];
    assign c[1173:1172] = a[1033:1032];
    assign c[1175:1174] = a[1183:1182];
    assign c[1177:1176] = a[393:392];
    assign c[1179:1178] = a[1035:1034];
    assign c[1181:1180] = {a[714], a[715]};
    assign c[1183:1182] = a[395:394];
    assign c[1185:1184] = a[1037:1036];
endmodule
/* c == v2(a) */
module v2(a, c);
    input [1185:0] a;
    output [1185:0] c;
    assign c[1:0] = 0;
    assign c[3:2] = 0;
    assign c[5:4] = 0;
    assign c[7:6] = 0;
    assign c[9:8] = 0;
    assign c[11:10] = 0;
    assign c[13:12] = 0;
    assign c[15:14] = 0;
    assign c[17:16] = 0;
    assign c[19:18] = 0;
    assign c[21:20] = 0;
    assign c[23:22] = 0;
    assign c[25:24] = 0;
    assign c[27:26] = 0;
    assign c[29:28] = 0;
    assign c[31:30] = 0;
    assign c[33:32] = 0;
    assign c[35:34] = 0;
    assign c[37:36] = 0;
    assign c[39:38] = 0;
    assign c[41:40] = 0;
    assign c[43:42] = 0;
    assign c[45:44] = 0;
    assign c[47:46] = 0;
    assign c[49:48] = 0;
    assign c[51:50] = 0;
    assign c[53:52] = 0;
    assign c[55:54] = 0;
    assign c[57:56] = 0;
    assign c[59:58] = 0;
    assign c[61:60] = 0;
    assign c[63:62] = 0;
    assign c[65:64] = 0;
    assign c[67:66] = 0;
    assign c[69:68] = 0;
    assign c[71:70] = 0;
    assign c[73:72] = 0;
    assign c[75:74] = 0;
    assign c[77:76] = 0;
    assign c[79:78] = 0;
    assign c[81:80] = 0;
    assign c[83:82] = 0;
    assign c[85:84] = 0;
    assign c[87:86] = 0;
    assign c[89:88] = 0;
    assign c[91:90] = 0;
    assign c[93:92] = 0;
    assign c[95:94] = 0;
    assign c[97:96] = 0;
    assign c[99:98] = 0;
    assign c[101:100] = 0;
    assign c[103:102] = 0;
    assign c[105:104] = 0;
    assign c[107:106] = 0;
    assign c[109:108] = 0;
    assign c[111:110] = 0;
    assign c[113:112] = 0;
    assign c[115:114] = 0;
    assign c[117:116] = 0;
    assign c[119:118] = 0;
    assign c[121:120] = 0;
    assign c[123:122] = 0;
    assign c[125:124] = 0;
    assign c[127:126] = 0;
    assign c[129:128] = 0;
    assign c[131:130] = 0;
    assign c[133:132] = 0;
    assign c[135:134] = 0;
    assign c[137:136] = 0;
    assign c[139:138] = 0;
    assign c[141:140] = 0;
    assign c[143:142] = 0;
    assign c[145:144] = 0;
    assign c[147:146] = 0;
    assign c[149:148] = 0;
    assign c[151:150] = 0;
    assign c[153:152] = 0;
    assign c[155:154] = 0;
    assign c[157:156] = 0;
    assign c[159:158] = 0;
    assign c[161:160] = 0;
    assign c[163:162] = 0;
    assign c[165:164] = 0;
    assign c[167:166] = 0;
    assign c[169:168] = 0;
    assign c[171:170] = 0;
    assign c[173:172] = 0;
    assign c[175:174] = 0;
    assign c[177:176] = 0;
    assign c[179:178] = 0;
    assign c[181:180] = 0;
    assign c[183:182] = 0;
    assign c[185:184] = 0;
    assign c[187:186] = 0;
    assign c[189:188] = 0;
    assign c[191:190] = 0;
    assign c[193:192] = 0;
    assign c[195:194] = 0;
    assign c[197:196] = 0;
    assign c[199:198] = 0;
    assign c[201:200] = 0;
    assign c[203:202] = 0;
    assign c[205:204] = 0;
    assign c[207:206] = 0;
    assign c[209:208] = 0;
    assign c[211:210] = 0;
    assign c[213:212] = 0;
    assign c[215:214] = 0;
    assign c[217:216] = 0;
    assign c[219:218] = 0;
    assign c[221:220] = 0;
    assign c[223:222] = 0;
    assign c[225:224] = 0;
    assign c[227:226] = 0;
    assign c[229:228] = {a[1038], a[1039]};
    assign c[231:230] = 0;
    assign c[233:232] = 0;
    assign c[235:234] = a[79:78];
    assign c[237:236] = 0;
    assign c[239:238] = 0;
    assign c[241:240] = a[797:796];
    assign c[243:242] = 0;
    assign c[245:244] = 0;
    assign c[247:246] = a[799:798];
    assign c[249:248] = 0;
    assign c[251:250] = 0;
    assign c[253:252] = {a[1046], a[1047]};
    assign c[255:254] = 0;
    assign c[257:256] = 0;
    assign c[259:258] = {a[1048], a[1049]};
    assign c[261:260] = 0;
    assign c[263:262] = 0;
    assign c[265:264] = {a[1050], a[1051]};
    assign c[267:266] = 0;
    assign c[269:268] = 0;
    assign c[271:270] = {a[1052], a[1053]};
    assign c[273:272] = 0;
    assign c[275:274] = 0;
    assign c[277:276] = {a[1054], a[1055]};
    assign c[279:278] = 0;
    assign c[281:280] = 0;
    assign c[283:282] = a[95:94];
    assign c[285:284] = 0;
    assign c[287:286] = 0;
    assign c[289:288] = a[813:812];
    assign c[291:290] = 0;
    assign c[293:292] = 0;
    assign c[295:294] = a[815:814];
    assign c[297:296] = 0;
    assign c[299:298] = 0;
    assign c[301:300] = {a[1062], a[1063]};
    assign c[303:302] = 0;
    assign c[305:304] = 0;
    assign c[307:306] = {a[1064], a[1065]};
    assign c[309:308] = 0;
    assign c[311:310] = 0;
    assign c[313:312] = {a[1066], a[1067]};
    assign c[315:314] = 0;
    assign c[317:316] = 0;
    assign c[319:318] = {a[1068], a[1069]};
    assign c[321:320] = 0;
    assign c[323:322] = 0;
    assign c[325:324] = {a[1070], a[1071]};
    assign c[327:326] = 0;
    assign c[329:328] = 0;
    assign c[331:330] = a[111:110];
    assign c[333:332] = 0;
    assign c[335:334] = 0;
    assign c[337:336] = a[829:828];
    assign c[339:338] = 0;
    assign c[341:340] = 0;
    assign c[343:342] = a[831:830];
    assign c[345:344] = 0;
    assign c[347:346] = 0;
    assign c[349:348] = {a[1078], a[1079]};
    assign c[351:350] = 0;
    assign c[353:352] = 0;
    assign c[355:354] = {a[1080], a[1081]};
    assign c[357:356] = 0;
    assign c[359:358] = 0;
    assign c[361:360] = {a[1082], a[1083]};
    assign c[363:362] = 0;
    assign c[365:364] = 0;
    assign c[367:366] = {a[1084], a[1085]};
    assign c[369:368] = 0;
    assign c[371:370] = 0;
    assign c[373:372] = {a[1086], a[1087]};
    assign c[375:374] = 0;
    assign c[377:376] = 0;
    assign c[379:378] = a[127:126];
    assign c[381:380] = 0;
    assign c[383:382] = 0;
    assign c[385:384] = a[845:844];
    assign c[387:386] = 0;
    assign c[389:388] = 0;
    assign c[391:390] = a[847:846];
    assign c[393:392] = 0;
    assign c[395:394] = 0;
    assign c[397:396] = {a[1094], a[1095]};
    assign c[399:398] = 0;
    assign c[401:400] = 0;
    assign c[403:402] = {a[1096], a[1097]};
    assign c[405:404] = 0;
    assign c[407:406] = 0;
    assign c[409:408] = {a[1098], a[1099]};
    assign c[411:410] = 0;
    assign c[413:412] = 0;
    assign c[415:414] = {a[1100], a[1101]};
    assign c[417:416] = 0;
    assign c[419:418] = 0;
    assign c[421:420] = {a[1102], a[1103]};
    assign c[423:422] = 0;
    assign c[425:424] = 0;
    assign c[427:426] = a[143:142];
    assign c[429:428] = 0;
    assign c[431:430] = 0;
    assign c[433:432] = a[861:860];
    assign c[435:434] = 0;
    assign c[437:436] = 0;
    assign c[439:438] = a[863:862];
    assign c[441:440] = 0;
    assign c[443:442] = 0;
    assign c[445:444] = {a[1110], a[1111]};
    assign c[447:446] = 0;
    assign c[449:448] = 0;
    assign c[451:450] = {a[1112], a[1113]};
    assign c[453:452] = 0;
    assign c[455:454] = 0;
    assign c[457:456] = {a[1114], a[1115]};
    assign c[459:458] = 0;
    assign c[461:460] = 0;
    assign c[463:462] = {a[1116], a[1117]};
    assign c[465:464] = 0;
    assign c[467:466] = 0;
    assign c[469:468] = {a[1118], a[1119]};
    assign c[471:470] = 0;
    assign c[473:472] = 0;
    assign c[475:474] = a[159:158];
    assign c[477:476] = 0;
    assign c[479:478] = 0;
    assign c[481:480] = a[877:876];
    assign c[483:482] = 0;
    assign c[485:484] = 0;
    assign c[487:486] = a[879:878];
    assign c[489:488] = 0;
    assign c[491:490] = 0;
    assign c[493:492] = {a[1126], a[1127]};
    assign c[495:494] = 0;
    assign c[497:496] = 0;
    assign c[499:498] = {a[1128], a[1129]};
    assign c[501:500] = 0;
    assign c[503:502] = 0;
    assign c[505:504] = {a[1130], a[1131]};
    assign c[507:506] = 0;
    assign c[509:508] = 0;
    assign c[511:510] = {a[1132], a[1133]};
    assign c[513:512] = 0;
    assign c[515:514] = 0;
    assign c[517:516] = {a[1134], a[1135]};
    assign c[519:518] = 0;
    assign c[521:520] = 0;
    assign c[523:522] = a[175:174];
    assign c[525:524] = 0;
    assign c[527:526] = 0;
    assign c[529:528] = a[893:892];
    assign c[531:530] = 0;
    assign c[533:532] = 0;
    assign c[535:534] = a[895:894];
    assign c[537:536] = 0;
    assign c[539:538] = 0;
    assign c[541:540] = {a[1142], a[1143]};
    assign c[543:542] = 0;
    assign c[545:544] = 0;
    assign c[547:546] = {a[1144], a[1145]};
    assign c[549:548] = 0;
    assign c[551:550] = 0;
    assign c[553:552] = {a[1146], a[1147]};
    assign c[555:554] = 0;
    assign c[557:556] = 0;
    assign c[559:558] = {a[1148], a[1149]};
    assign c[561:560] = 0;
    assign c[563:562] = 0;
    assign c[565:564] = {a[1150], a[1151]};
    assign c[567:566] = 0;
    assign c[569:568] = 0;
    assign c[571:570] = a[191:190];
    assign c[573:572] = 0;
    assign c[575:574] = 0;
    assign c[577:576] = a[909:908];
    assign c[579:578] = 0;
    assign c[581:580] = 0;
    assign c[583:582] = a[911:910];
    assign c[585:584] = 0;
    assign c[587:586] = 0;
    assign c[589:588] = {a[1158], a[1159]};
    assign c[591:590] = 0;
    assign c[593:592] = 0;
    assign c[595:594] = {a[1160], a[1161]};
    assign c[597:596] = 0;
    assign c[599:598] = 0;
    assign c[601:600] = {a[1162], a[1163]};
    assign c[603:602] = 0;
    assign c[605:604] = 0;
    assign c[607:606] = {a[1164], a[1165]};
    assign c[609:608] = 0;
    assign c[611:610] = 0;
    assign c[613:612] = {a[1166], a[1167]};
    assign c[615:614] = 0;
    assign c[617:616] = 0;
    assign c[619:618] = a[207:206];
    assign c[621:620] = 0;
    assign c[623:622] = 0;
    assign c[625:624] = a[925:924];
    assign c[627:626] = 0;
    assign c[629:628] = 0;
    assign c[631:630] = a[927:926];
    assign c[633:632] = 0;
    assign c[635:634] = 0;
    assign c[637:636] = {a[1174], a[1175]};
    assign c[639:638] = 0;
    assign c[641:640] = 0;
    assign c[643:642] = {a[1176], a[1177]};
    assign c[645:644] = 0;
    assign c[647:646] = 0;
    assign c[649:648] = {a[1178], a[1179]};
    assign c[651:650] = 0;
    assign c[653:652] = 0;
    assign c[655:654] = {a[1180], a[1181]};
    assign c[657:656] = 0;
    assign c[659:658] = 0;
    assign c[661:660] = {a[1182], a[1183]};
    assign c[663:662] = 0;
    assign c[665:664] = 0;
    assign c[667:666] = a[223:222];
    assign c[669:668] = 0;
    assign c[671:670] = 0;
    assign c[673:672] = 0;
    assign c[675:674] = 0;
    assign c[677:676] = 0;
    assign c[679:678] = 0;
    assign c[681:680] = 0;
    assign c[683:682] = 0;
    assign c[685:684] = 0;
    assign c[687:686] = 0;
    assign c[689:688] = 0;
    assign c[691:690] = 0;
    assign c[693:692] = 0;
    assign c[695:694] = 0;
    assign c[697:696] = 0;
    assign c[699:698] = 0;
    assign c[701:700] = 0;
    assign c[703:702] = 0;
    assign c[705:704] = 0;
    assign c[707:706] = 0;
    assign c[709:708] = 0;
    assign c[711:710] = 0;
    assign c[713:712] = 0;
    assign c[715:714] = 0;
    assign c[717:716] = 0;
    assign c[719:718] = 0;
    assign c[721:720] = 0;
    assign c[723:722] = 0;
    assign c[725:724] = 0;
    assign c[727:726] = 0;
    assign c[729:728] = 0;
    assign c[731:730] = 0;
    assign c[733:732] = 0;
    assign c[735:734] = 0;
    assign c[737:736] = 0;
    assign c[739:738] = 0;
    assign c[741:740] = 0;
    assign c[743:742] = 0;
    assign c[745:744] = 0;
    assign c[747:746] = 0;
    assign c[749:748] = 0;
    assign c[751:750] = 0;
    assign c[753:752] = 0;
    assign c[755:754] = 0;
    assign c[757:756] = 0;
    assign c[759:758] = 0;
    assign c[761:760] = 0;
    assign c[763:762] = 0;
    assign c[765:764] = 0;
    assign c[767:766] = 0;
    assign c[769:768] = 0;
    assign c[771:770] = 0;
    assign c[773:772] = 0;
    assign c[775:774] = 0;
    assign c[777:776] = 0;
    assign c[779:778] = 0;
    assign c[781:780] = 0;
    assign c[783:782] = 0;
    assign c[785:784] = 0;
    assign c[787:786] = 0;
    assign c[789:788] = 0;
    assign c[791:790] = 0;
    assign c[793:792] = 0;
    assign c[795:794] = 0;
    assign c[797:796] = 0;
    assign c[799:798] = 0;
    assign c[801:800] = 0;
    assign c[803:802] = 0;
    assign c[805:804] = 0;
    assign c[807:806] = 0;
    assign c[809:808] = 0;
    assign c[811:810] = 0;
    assign c[813:812] = 0;
    assign c[815:814] = 0;
    assign c[817:816] = 0;
    assign c[819:818] = 0;
    assign c[821:820] = 0;
    assign c[823:822] = 0;
    assign c[825:824] = 0;
    assign c[827:826] = 0;
    assign c[829:828] = 0;
    assign c[831:830] = 0;
    assign c[833:832] = 0;
    assign c[835:834] = 0;
    assign c[837:836] = 0;
    assign c[839:838] = 0;
    assign c[841:840] = 0;
    assign c[843:842] = 0;
    assign c[845:844] = 0;
    assign c[847:846] = 0;
    assign c[849:848] = 0;
    assign c[851:850] = 0;
    assign c[853:852] = 0;
    assign c[855:854] = 0;
    assign c[857:856] = 0;
    assign c[859:858] = 0;
    assign c[861:860] = 0;
    assign c[863:862] = 0;
    assign c[865:864] = 0;
    assign c[867:866] = 0;
    assign c[869:868] = 0;
    assign c[871:870] = 0;
    assign c[873:872] = 0;
    assign c[875:874] = 0;
    assign c[877:876] = 0;
    assign c[879:878] = 0;
    assign c[881:880] = 0;
    assign c[883:882] = 0;
    assign c[885:884] = 0;
    assign c[887:886] = 0;
    assign c[889:888] = 0;
    assign c[891:890] = 0;
    assign c[893:892] = 0;
    assign c[895:894] = 0;
    assign c[897:896] = 0;
    assign c[899:898] = 0;
    assign c[901:900] = 0;
    assign c[903:902] = 0;
    assign c[905:904] = 0;
    assign c[907:906] = 0;
    assign c[909:908] = 0;
    assign c[911:910] = 0;
    assign c[913:912] = 0;
    assign c[915:914] = 0;
    assign c[917:916] = 0;
    assign c[919:918] = 0;
    assign c[921:920] = 0;
    assign c[923:922] = 0;
    assign c[925:924] = 0;
    assign c[927:926] = 0;
    assign c[929:928] = 0;
    assign c[931:930] = 0;
    assign c[933:932] = 0;
    assign c[935:934] = 0;
    assign c[937:936] = 0;
    assign c[939:938] = 0;
    assign c[941:940] = 0;
    assign c[943:942] = 0;
    assign c[945:944] = 0;
    assign c[947:946] = 0;
    assign c[949:948] = 0;
    assign c[951:950] = 0;
    assign c[953:952] = 0;
    assign c[955:954] = 0;
    assign c[957:956] = 0;
    assign c[959:958] = 0;
    assign c[961:960] = 0;
    assign c[963:962] = 0;
    assign c[965:964] = 0;
    assign c[967:966] = 0;
    assign c[969:968] = 0;
    assign c[971:970] = 0;
    assign c[973:972] = 0;
    assign c[975:974] = 0;
    assign c[977:976] = 0;
    assign c[979:978] = 0;
    assign c[981:980] = 0;
    assign c[983:982] = 0;
    assign c[985:984] = 0;
    assign c[987:986] = 0;
    assign c[989:988] = 0;
    assign c[991:990] = 0;
    assign c[993:992] = 0;
    assign c[995:994] = 0;
    assign c[997:996] = 0;
    assign c[999:998] = 0;
    assign c[1001:1000] = 0;
    assign c[1003:1002] = 0;
    assign c[1005:1004] = 0;
    assign c[1007:1006] = 0;
    assign c[1009:1008] = 0;
    assign c[1011:1010] = 0;
    assign c[1013:1012] = 0;
    assign c[1015:1014] = 0;
    assign c[1017:1016] = 0;
    assign c[1019:1018] = 0;
    assign c[1021:1020] = 0;
    assign c[1023:1022] = 0;
    assign c[1025:1024] = 0;
    assign c[1027:1026] = 0;
    assign c[1029:1028] = 0;
    assign c[1031:1030] = 0;
    assign c[1033:1032] = 0;
    assign c[1035:1034] = 0;
    assign c[1037:1036] = 0;
    assign c[1039:1038] = 0;
    assign c[1041:1040] = 0;
    assign c[1043:1042] = 0;
    assign c[1045:1044] = 0;
    assign c[1047:1046] = 0;
    assign c[1049:1048] = 0;
    assign c[1051:1050] = 0;
    assign c[1053:1052] = 0;
    assign c[1055:1054] = 0;
    assign c[1057:1056] = 0;
    assign c[1059:1058] = 0;
    assign c[1061:1060] = 0;
    assign c[1063:1062] = 0;
    assign c[1065:1064] = 0;
    assign c[1067:1066] = 0;
    assign c[1069:1068] = 0;
    assign c[1071:1070] = 0;
    assign c[1073:1072] = 0;
    assign c[1075:1074] = 0;
    assign c[1077:1076] = 0;
    assign c[1079:1078] = 0;
    assign c[1081:1080] = 0;
    assign c[1083:1082] = 0;
    assign c[1085:1084] = 0;
    assign c[1087:1086] = 0;
    assign c[1089:1088] = 0;
    assign c[1091:1090] = 0;
    assign c[1093:1092] = 0;
    assign c[1095:1094] = 0;
    assign c[1097:1096] = 0;
    assign c[1099:1098] = 0;
    assign c[1101:1100] = 0;
    assign c[1103:1102] = 0;
    assign c[1105:1104] = 0;
    assign c[1107:1106] = 0;
    assign c[1109:1108] = 0;
    assign c[1111:1110] = 0;
    assign c[1113:1112] = 0;
    assign c[1115:1114] = 0;
    assign c[1117:1116] = 0;
    assign c[1119:1118] = 0;
    assign c[1121:1120] = 0;
    assign c[1123:1122] = 0;
    assign c[1125:1124] = 0;
    assign c[1127:1126] = 0;
    assign c[1129:1128] = 0;
    assign c[1131:1130] = 0;
    assign c[1133:1132] = 0;
    assign c[1135:1134] = 0;
    assign c[1137:1136] = 0;
    assign c[1139:1138] = 0;
    assign c[1141:1140] = 0;
    assign c[1143:1142] = 0;
    assign c[1145:1144] = 0;
    assign c[1147:1146] = 0;
    assign c[1149:1148] = 0;
    assign c[1151:1150] = 0;
    assign c[1153:1152] = 0;
    assign c[1155:1154] = 0;
    assign c[1157:1156] = 0;
    assign c[1159:1158] = 0;
    assign c[1161:1160] = 0;
    assign c[1163:1162] = 0;
    assign c[1165:1164] = 0;
    assign c[1167:1166] = 0;
    assign c[1169:1168] = 0;
    assign c[1171:1170] = 0;
    assign c[1173:1172] = 0;
    assign c[1175:1174] = 0;
    assign c[1177:1176] = 0;
    assign c[1179:1178] = 0;
    assign c[1181:1180] = 0;
    assign c[1183:1182] = 0;
    assign c[1185:1184] = 0;
endmodule
/*
 * Copyright 2012, Homer Hsing <homer.hsing@gmail.com>
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 * http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */

/* FSM: finite state machine 
 * halt if $ctrl == 0$
 */
module FSM(clk, reset, rom_addr, rom_q, ram_a_addr, ram_b_addr, ram_b_w, pe, done);
    input clk;
    input reset;
    output reg [8:0] rom_addr; /* command id. extra bits? */
    input [28:0] rom_q; /* command value */
    output reg [5:0] ram_a_addr;
    output reg [5:0] ram_b_addr;
    output ram_b_w;
    output reg [10:0] pe;
    output reg done;
    
    reg [5:0] state;
    parameter START=0, READ_SRC1=1, READ_SRC2=2, CALC=4, WAIT=8, WRITE=16, DON=32;
	
    wire [5:0] dest, src1, src2; wire [8:0] times; wire [1:0] op;
    assign {dest, src1, op, times, src2} = rom_q;

    reg [8:0] count;
	
    always @ (posedge clk)
       if (reset) 
          state<=START; 
       else 
          case (state)
             START:
                state<=READ_SRC1;
             READ_SRC1:
                state<=READ_SRC2;
             READ_SRC2:
                if (times==0) state<=DON; else state<=CALC;
             CALC:
                if (count==1) state<=WAIT;
             WAIT:
                state<=WRITE;
             WRITE:
                state<=READ_SRC1;
          endcase

    /* we support two loops */
    parameter  LOOP1_START = 9'd21,
               LOOP1_END   = 9'd116,
               LOOP2_START = 9'd288,
               LOOP2_END   = 9'd301;
    reg [294:0] loop1, loop2;
	
	always @ (posedge clk)
	   if (reset) rom_addr<=0;
	   else if (state==WAIT)
          begin
             if(rom_addr == LOOP1_END && loop1[0])
                rom_addr <= LOOP1_START;
             else if(rom_addr == LOOP2_END && loop2[0])
                rom_addr <= LOOP2_START;
             else
                rom_addr <= rom_addr + 1'd1; 
	      end
	
	always @ (posedge clk)
	   if (reset) loop1 <= ~0;
	   else if(state==WAIT && rom_addr==LOOP1_END)
          loop1 <= loop1 >> 1;
	
	always @ (posedge clk)
	   if (reset) loop2 <= ~0;
	   else if(state==WAIT && rom_addr==LOOP2_END)
          loop2 <= loop2 >> 1;

	always @ (posedge clk)
	   if (reset)
          count <= 0;
	   else if (state==READ_SRC1)
          count <= times;
	   else if (state==CALC)
          count <= count - 1'd1;
	
	always @ (posedge clk)
	   if (reset) done<=0;
	   else if (state==DON) done<=1;
	   else done<=0;
	 
    always @ (state, src1, src2)
       case (state)
       READ_SRC1: ram_a_addr=src1;
       READ_SRC2: ram_a_addr=src2;
       default: ram_a_addr=0;
       endcase
    
    parameter CMD_ADD=6'd4, CMD_SUB=6'd8, CMD_CUBIC=6'd16,
              ADD=2'd0, SUB=2'd1, CUBIC=2'd2, MULT=2'd3;

    always @ (posedge clk)
       case (state)
       READ_SRC1:
          case (op)
          ADD:   pe<=11'b11001000000;
          SUB:   pe<=11'b11001000000;
          CUBIC: pe<=11'b11111000000;
          MULT:  pe<=11'b11110000000;
          default: pe<=0;
          endcase
       READ_SRC2:
          case (op)
          ADD:   pe<=11'b00110000000;
          SUB:   pe<=11'b00110000000;
          CUBIC: pe<=0;
          MULT:  pe<=11'b00001000000;
          default: pe<=0;
          endcase
       CALC:
          case (op)
          ADD:   pe<=11'b00000010001;
          SUB:   pe<=11'b00000010001;
          CUBIC: pe<=11'b01010000001;
          MULT:  pe<=11'b00000111111;
          default: pe<=0;
          endcase
       default: 
          pe<=0;
       endcase

    always @ (state, op, src2, dest)
       case (state)
       READ_SRC1: 
          case (op)
          ADD: ram_b_addr=CMD_ADD;
          SUB: ram_b_addr=CMD_SUB;
          CUBIC: ram_b_addr=CMD_CUBIC;
          default: ram_b_addr=0;
          endcase
       READ_SRC2: ram_b_addr=src2;
       WRITE: ram_b_addr=dest;
       default: ram_b_addr=0;
       endcase

    assign ram_b_w = (state==WRITE) ? 1'b1 : 1'b0;
endmodule
/*
 * Copyright 2012, Homer Hsing <homer.hsing@gmail.com>
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 * http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */

`define M     593         // M is the degree of the irreducible polynomial
`define WIDTH (2*`M-1)    // width for a GF(3^M) element
`define WIDTH_D0 1187

module pairing(clk, reset, sel, addr, w, update, ready, i, o, done);
   input clk;
   input reset; // for the arithmethic core
   input sel;
   input [5:0] addr;
   input w;
   input update; // update reg_in & reg_out
   input ready;  // shift reg_in & reg_out
   input i;
   output o;
   output done;
   
   reg [`WIDTH_D0:0] reg_in, reg_out;
   wire [`WIDTH_D0:0] out;
   
   assign o = reg_out[0];
   
   tiny
      tiny0 (clk, reset, sel, addr, w, reg_in, out, done);
   
   always @ (posedge clk) // write LSB firstly
      if (update) reg_in <= 0;
      else if (ready) reg_in <= {i,reg_in[`WIDTH_D0:1]};
   
   always @ (posedge clk) // read LSB firstly
      if (update) reg_out <= out;
      else if (ready) reg_out <= reg_out>>1;
endmodule
/*
 * Copyright 2012, Homer Hsing <homer.hsing@gmail.com>
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 * http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */

`define M     593         // M is the degree of the irreducible polynomial
`define WIDTH (2*`M-1)    // width for a GF(3^M) element
`define WIDTH_D0 1187

/* PE: processing element */
module PE(clk, reset, ctrl, d0, d1, d2, out);
    input clk;
    input reset;
    input [10:0] ctrl;
    input [`WIDTH_D0:0] d0;
    input [`WIDTH:0] d1, d2;
    output [`WIDTH:0] out;
    
    reg [`WIDTH_D0:0] R0;
    reg [`WIDTH:0] R1, R2, R3;
    wire [1:0] e0, e1, e2; /* part of R0 */
    wire [`WIDTH:0] ppg0, ppg1, ppg2, /* output of PPG */
                    mx0, mx1, mx2, mx3, mx4, mx5, mx6, /* output of MUX */
                    ad0, ad1, ad2, /* output of GF(3^m) adder */
                    cu0, cu1, cu2, /* output of cubic */
                    mo0, mo1, mo2, /* output of mod_p */
                    t0, t1, t2;
    wire c0,c1,c2,c3,c4,c5,c6,c7,c8,c9,c10;
    
    assign {c0,c1,c2,c3,c4,c5,c6,c7,c8,c9,c10} = ctrl;
    assign mx0 = c0 ? d1 : ad2;
    assign mx1 = c2 ? d2 : ad2;
    always @ (posedge clk)
        if(reset) R1 <= 0;
        else if (c1) R1 <= mx0;
    always @ (posedge clk)
        if(reset) R2 <= 0;
        else if (c3) R2 <= mx1;
    always @ (posedge clk)
        if(reset) R0 <= 0;
        else if (c4) R0 <= d0;
        else if (c5) R0 <= R0 << 6;
    assign {e2,e1,e0} = R0[`WIDTH_D0:(`WIDTH_D0-5)];
    PPG
        ppg_0 (e0, R1, ppg0),
        ppg_1 (e1, R2, ppg1),
        ppg_2 (e2, R1, ppg2);
    v0  v0_ (ppg0, cu0);
    v1  v1_ (ppg1, cu1);
    v2  v2_ (ppg2, cu2);
    assign mx2 = c6 ? ppg0 : cu0;
    assign mx3 = c6 ? ppg1 : cu1;
    assign mx4 = c6 ? mo1 : cu2;
    assign mx5 = c7 ? mo2 : R3;
    mod_p
        mod_p_0 (mx3, mo0),
        mod_p_1 (ppg2, t0),
        mod_p_2 (t0, mo1),
        mod_p_3 (R3, t1),
        mod_p_4 (t1, t2),
        mod_p_5 (t2, mo2);
    assign mx6 = c9 ? mo0 : mx3;
    f3m_add
        f3m_add_0 (mx2, mx6, ad0),
        f3m_add_1 (mx4, c8 ? mx5 : 0, ad1),
        f3m_add_2 (ad0, ad1, ad2);
    always @ (posedge clk)
        if (reset) R3 <= 0;
        else if (c10) R3 <= ad2;
        else R3 <= 0; /* change */
    assign out = R3;
endmodule

// C = (x*B mod p(x))
module mod_p(B, C);
    input [`WIDTH:0] B;
    output [`WIDTH:0] C;
    wire [`WIDTH+2:0] A;
    assign A = {B[`WIDTH:0], 2'd0}; // A == B*x
    wire [1:0] w0;
    f3_mult m0 (A[1187:1186], 2'd2, w0);
    f3_sub s0 (A[1:0], w0, C[1:0]);
    assign C[223:2] = A[223:2];
    wire [1:0] w112;
    f3_mult m112 (A[1187:1186], 2'd1, w112);
    f3_sub s112 (A[225:224], w112, C[225:224]);
    assign C[1185:226] = A[1185:226];
endmodule

// PPG: partial product generator, C == A*d in GF(3^m)
module PPG(d, A, C);
    input [1:0] d;
    input [`WIDTH:0] A;
    output [`WIDTH:0] C;
    genvar i;
    generate
        for (i=0; i < `M; i=i+1) 
        begin: ppg0
            f3_mult f3_mult_0 (d, A[2*i+1:2*i], C[2*i+1:2*i]);
        end
    endgenerate
endmodule

// f3m_add: C = A + B, in field F_{3^M}
module f3m_add(A, B, C);
    input [`WIDTH : 0] A, B;
    output [`WIDTH : 0] C;
    genvar i;
    generate
        for(i=0; i<`M; i=i+1) begin: aa
            f3_add aa(A[(2*i+1) : 2*i], B[(2*i+1) : 2*i], C[(2*i+1) : 2*i]);
        end
    endgenerate
endmodule

// f3_add: C == A+B (mod 3)
module f3_add(A, B, C);
    input [1:0] A, B;
    output [1:0] C;
    wire a0, a1, b0, b1, c0, c1;
    assign {a1, a0} = A;
    assign {b1, b0} = B;
    assign C = {c1, c0};
    assign c0 = ( a0 & ~a1 & ~b0 & ~b1) |
                (~a0 & ~a1 &  b0 & ~b1) |
                (~a0 &  a1 & ~b0 &  b1) ;
    assign c1 = (~a0 &  a1 & ~b0 & ~b1) |
                ( a0 & ~a1 &  b0 & ~b1) |
                (~a0 & ~a1 & ~b0 &  b1) ;
endmodule

// f3_sub: C == A-B (mod 3)
module f3_sub(A, B, C);
    input [1:0] A, B;
    output [1:0] C;
    f3_add a0(A, {B[0],B[1]}, C);
endmodule

// f3_mult: C = A*B (mod 3)
module f3_mult(A, B, C); 
    input [1:0] A;
    input [1:0] B; 
    output [1:0] C;
    wire a0, a1, b0, b1;
    assign {a1, a0} = A;
    assign {b1, b0} = B;
    assign C[0] = (~a1 & a0 & ~b1 & b0) | (a1 & ~a0 & b1 & ~b0);
    assign C[1] = (~a1 & a0 & b1 & ~b0) | (a1 & ~a0 & ~b1 & b0);
endmodule
/*
 * Copyright 2012, Homer Hsing <homer.hsing@gmail.com>
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 * http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */

`define M     593         // M is the degree of the irreducible polynomial
`define WIDTH (2*`M-1)    // width for a GF(3^M) element
`define WIDTH_D0 1187

module ram #(
    parameter DATA = 1188,
    parameter ADDR = 6
) (
    input                       clk,

    // Port A
    input   wire                a_wr,
    input   wire    [ADDR-1:0]  a_addr,
    input   wire    [DATA-1:0]  a_din,
    output  reg     [DATA-1:0]  a_dout,
    
    // Port B
    input   wire                b_wr,
    input   wire    [ADDR-1:0]  b_addr,
    input   wire    [DATA-1:0]  b_din,
    output  reg     [DATA-1:0]  b_dout
);

    // Shared memory
    reg [DATA-1:0] mem [(2**ADDR)-1:0];

    initial begin : init
        integer i;
        for(i = 0; i < (2**ADDR); i = i + 1)
            mem[i] = 0;
    end

    // Port A
    always @(posedge clk) begin
        a_dout      <= mem[a_addr];
        if(a_wr) begin
            a_dout      <= a_din;
            mem[a_addr] <= a_din;
        end
    end

    // Port B
    always @(posedge clk) begin
        b_dout      <= mem[b_addr];
        if(b_wr) begin
            b_dout      <= b_din;
            mem[b_addr] <= b_din;
        end
    end

endmodule
/*
 * Copyright 2012, Homer Hsing <homer.hsing@gmail.com>
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 * http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */

module rom (clk, addr, out);
   input clk;
   input [8:0] addr;
   output reg [28:0] out;
   
   always @(posedge clk)
      case (addr)
         0: out <= 29'h1860042;
         1: out <= 29'h30d0041;
         2: out <= 29'h38f0041;
         3: out <= 29'h60046;
         4: out <= 29'hb01b180;
         5: out <= 29'hb810041;
         6: out <= 29'hb8bb197;
         7: out <= 29'hc0bb187;
         8: out <= 29'hcb1b187;
         9: out <= 29'h7ae8059;
         10: out <= 29'h79e8045;
         11: out <= 29'hbb1b185;
         12: out <= 29'hc2fb180;
         13: out <= 29'hb0fb196;
         14: out <= 29'h8b00056;
         15: out <= 29'h8a20051;
         16: out <= 29'h90a0045;
         17: out <= 29'h98fb180;
         18: out <= 29'h9ae8053;
         19: out <= 29'ha020041;
         20: out <= 29'ha8e0047;
         21: out <= 29'h1f0041;
         22: out <= 29'hb230041;
         23: out <= 29'hba50041;
         24: out <= 29'hc270041;
         25: out <= 29'hca90041;
         26: out <= 29'hd2b0041;
         27: out <= 29'h7800057;
         28: out <= 29'h79e0059;
         29: out <= 29'h8ac0058;
         30: out <= 29'h8a2005a;
         31: out <= 29'h8a20051;
         32: out <= 29'h92e8059;
         33: out <= 29'h9b48058;
         34: out <= 29'ha320041;
         35: out <= 29'hab4005a;
         36: out <= 29'h30d0081;
         37: out <= 29'h30c8042;
         38: out <= 29'h38f0081;
         39: out <= 29'h38e0047;
         40: out <= 29'h60046;
         41: out <= 29'hb000040;
         42: out <= 29'hb8bb187;
         43: out <= 29'h2db180;
         44: out <= 29'hc000056;
         45: out <= 29'hc808056;
         46: out <= 29'hd1e0054;
         47: out <= 29'hdb40052;
         48: out <= 29'he348052;
         49: out <= 29'he9e8054;
         50: out <= 29'hf3a8053;
         51: out <= 29'heba0053;
         52: out <= 29'hfa20055;
         53: out <= 29'h103e0053;
         54: out <= 29'h10be8053;
         55: out <= 29'h112e0056;
         56: out <= 29'hb2e8056;
         57: out <= 29'h11a28055;
         58: out <= 29'h12460052;
         59: out <= 29'h11c68052;
         60: out <= 29'h12b00057;
         61: out <= 29'h13360060;
         62: out <= 29'h13800062;
         63: out <= 29'h143c0064;
         64: out <= 29'h14b20057;
         65: out <= 29'h15380061;
         66: out <= 29'h15800056;
         67: out <= 29'h163a0063;
         68: out <= 29'hc31b19b;
         69: out <= 29'hdcbb1a6;
         70: out <= 29'h102fb1a0;
         71: out <= 29'hf01b19e;
         72: out <= 29'h12cfb1a8;
         73: out <= 29'h1145b1a4;
         74: out <= 29'hcb3b19c;
         75: out <= 29'he53b1aa;
         76: out <= 29'hbafb1a1;
         77: out <= 29'h1b19d;
         78: out <= 29'hed7b1ac;
         79: out <= 29'hb2db1a3;
         80: out <= 29'h10b00065;
         81: out <= 29'h11c0005d;
         82: out <= 29'h12408057;
         83: out <= 29'h13328058;
         84: out <= 29'hbae0060;
         85: out <= 29'hbc48057;
         86: out <= 29'hbae0056;
         87: out <= 29'hc320058;
         88: out <= 29'hc30805e;
         89: out <= 29'hc308040;
         90: out <= 29'hcc68061;
         91: out <= 29'hcb2805e;
         92: out <= 29'hb320056;
         93: out <= 29'hcc20063;
         94: out <= 29'hcb2805b;
         95: out <= 29'hcb20062;
         96: out <= 29'h320040;
         97: out <= 29'hcc80066;
         98: out <= 29'hf488066;
         99: out <= 29'hf3c005c;
         100: out <= 29'hf3c805b;
         101: out <= 29'h102e0058;
         102: out <= 29'hbae8058;
         103: out <= 29'hbae005c;
         104: out <= 29'hbae005b;
         105: out <= 29'hbae8065;
         106: out <= 29'hbae805d;
         107: out <= 29'h7ac8052;
         108: out <= 29'h8808053;
         109: out <= 29'h328052;
         110: out <= 29'h8054;
         111: out <= 29'hb3c8053;
         112: out <= 29'hb2c8055;
         113: out <= 29'ha40805a;
         114: out <= 29'haae805f;
         115: out <= 29'h9008041;
         116: out <= 29'h9ac8041;
         117: out <= 29'h49f0041;
         118: out <= 29'h1e0052;
         119: out <= 29'h54;
         120: out <= 29'hb1fb18f;
         121: out <= 29'hb9fb192;
         122: out <= 29'hc25b194;
         123: out <= 29'hca9b194;
         124: out <= 29'h1b180;
         125: out <= 29'hbae0058;
         126: out <= 29'hc2c8058;
         127: out <= 29'hcb28057;
         128: out <= 29'h57;
         129: out <= 29'h8056;
         130: out <= 29'hb220053;
         131: out <= 29'hb2c0055;
         132: out <= 29'hba3b191;
         133: out <= 29'hd23b193;
         134: out <= 29'hda7b195;
         135: out <= 29'he2bb195;
         136: out <= 29'hb2db196;
         137: out <= 29'hd34005b;
         138: out <= 29'hdae805b;
         139: out <= 29'he38805a;
         140: out <= 29'hb2c005a;
         141: out <= 29'hb2c8057;
         142: out <= 29'hb9e0052;
         143: out <= 29'hd1e0054;
         144: out <= 29'hea40054;
         145: out <= 29'hf220053;
         146: out <= 29'hfa20055;
         147: out <= 29'h10260055;
         148: out <= 29'h109fb191;
         149: out <= 29'h1125b193;
         150: out <= 29'h11a9b195;
         151: out <= 29'hbafb19e;
         152: out <= 29'hd35b19f;
         153: out <= 29'hebbb1a0;
         154: out <= 29'hf428062;
         155: out <= 29'hfbc8063;
         156: out <= 29'hfbe005d;
         157: out <= 29'hbae805e;
         158: out <= 29'hbae005d;
         159: out <= 29'hd34805e;
         160: out <= 29'heb0805b;
         161: out <= 29'hf32805c;
         162: out <= 29'h10008056;
         163: out <= 29'hc30005b;
         164: out <= 29'hcb2005c;
         165: out <= 29'h56;
         166: out <= 29'hb300059;
         167: out <= 29'hdb08040;
         168: out <= 29'he328058;
         169: out <= 29'h1080805c;
         170: out <= 29'h1131b198;
         171: out <= 29'h11b3b199;
         172: out <= 29'h1201b180;
         173: out <= 29'hcb1b199;
         174: out <= 29'hc31b180;
         175: out <= 29'h1b196;
         176: out <= 29'hb45b19b;
         177: out <= 29'hdc7b19c;
         178: out <= 29'he49b1a1;
         179: out <= 29'hb2c005b;
         180: out <= 29'hb2c005c;
         181: out <= 29'hdac0041;
         182: out <= 29'he370041;
         183: out <= 29'he37b19c;
         184: out <= 29'h10b90041;
         185: out <= 29'hdb7b1a1;
         186: out <= 29'h10b70081;
         187: out <= 29'he39b1a1;
         188: out <= 29'h10b900c1;
         189: out <= 29'hdb7b1a1;
         190: out <= 29'h10b70201;
         191: out <= 29'hdb7b1a1;
         192: out <= 29'h10b70141;
         193: out <= 29'he39b1a1;
         194: out <= 29'he390401;
         195: out <= 29'hdb7b19c;
         196: out <= 29'he370941;
         197: out <= 29'hdb7b19c;
         198: out <= 29'he371281;
         199: out <= 29'hdb7b19c;
         200: out <= 29'he372501;
         201: out <= 29'hdb7b19c;
         202: out <= 29'he374a01;
         203: out <= 29'hdb7b19c;
         204: out <= 29'hdb70041;
         205: out <= 29'hb37b196;
         206: out <= 29'hb37b196;
         207: out <= 29'hdc68064;
         208: out <= 29'he44805b;
         209: out <= 29'h388040;
         210: out <= 29'hcc88059;
         211: out <= 29'hc368058;
         212: out <= 29'h2db180;
         213: out <= 29'hcadb199;
         214: out <= 29'hb2db198;
         215: out <= 29'hc3a005e;
         216: out <= 29'hdba0060;
         217: out <= 29'he3c0060;
         218: out <= 29'h10800059;
         219: out <= 29'h11000056;
         220: out <= 29'h11b20056;
         221: out <= 29'hebbb180;
         222: out <= 29'hf3db199;
         223: out <= 29'h1041b196;
         224: out <= 29'hc31b1a1;
         225: out <= 29'hdb7b1a2;
         226: out <= 29'he39b1a3;
         227: out <= 29'heba805e;
         228: out <= 29'hf3a8060;
         229: out <= 29'hf3c005c;
         230: out <= 29'hc30805d;
         231: out <= 29'hc30005c;
         232: out <= 29'hdb6805d;
         233: out <= 29'he3e0057;
         234: out <= 29'hebe005a;
         235: out <= 29'h102e005a;
         236: out <= 29'h10800059;
         237: out <= 29'h11000056;
         238: out <= 29'h11b20056;
         239: out <= 29'h3fb180;
         240: out <= 29'hbafb199;
         241: out <= 29'hb35b196;
         242: out <= 29'hcb9b1a1;
         243: out <= 29'hd3bb1a2;
         244: out <= 29'he41b1a3;
         245: out <= 29'h8057;
         246: out <= 29'hb008056;
         247: out <= 29'hb2c005c;
         248: out <= 29'hbb28040;
         249: out <= 29'hbae005c;
         250: out <= 29'h348040;
         251: out <= 29'hcbc0056;
         252: out <= 29'hd300057;
         253: out <= 29'he368040;
         254: out <= 29'hebdb19b;
         255: out <= 29'hfadb180;
         256: out <= 29'hdb1b19b;
         257: out <= 29'h2fb180;
         258: out <= 29'h1033b19c;
         259: out <= 29'hb2db198;
         260: out <= 29'hbbdb197;
         261: out <= 29'hc33b19a;
         262: out <= 29'hcb5b19c;
         263: out <= 29'hd2c0057;
         264: out <= 29'hc348058;
         265: out <= 29'hd360040;
         266: out <= 29'hd34005a;
         267: out <= 29'h805b;
         268: out <= 29'hdbe805d;
         269: out <= 29'hdb60060;
         270: out <= 29'he04005d;
         271: out <= 29'he38005f;
         272: out <= 29'he38805a;
         273: out <= 29'hb2e8056;
         274: out <= 29'hb360056;
         275: out <= 29'hbb00041;
         276: out <= 29'heb20040;
         277: out <= 29'hdba005b;
         278: out <= 29'hc30005a;
         279: out <= 29'hc300058;
         280: out <= 29'h320040;
         281: out <= 29'h40;
         282: out <= 29'hcb90041;
         283: out <= 29'hd2d0041;
         284: out <= 29'heaf0041;
         285: out <= 29'hf370041;
         286: out <= 29'hfb10041;
         287: out <= 29'h10010041;
         288: out <= 29'hcb2005d;
         289: out <= 29'hcb2005f;
         290: out <= 29'hd34005a;
         291: out <= 29'hd34805e;
         292: out <= 29'hd348060;
         293: out <= 29'heba805f;
         294: out <= 29'hf40805e;
         295: out <= 29'h10400060;
         296: out <= 29'hcb30041;
         297: out <= 29'hd350041;
         298: out <= 29'hebb0041;
         299: out <= 29'hf3d0041;
         300: out <= 29'hfbf0041;
         301: out <= 29'h10410041;
         302: out <= 29'hcb2005d;
         303: out <= 29'hcb2005f;
         304: out <= 29'hd34005a;
         305: out <= 29'hd34805e;
         306: out <= 29'hd348060;
         307: out <= 29'heba805f;
         308: out <= 29'hf40805e;
         309: out <= 29'h10400060;
         310: out <= 29'h10b80056;
         311: out <= 29'h112e005b;
         312: out <= 29'h11b08040;
         313: out <= 29'h1239b198;
         314: out <= 29'h12adb180;
         315: out <= 29'hc2fb198;
         316: out <= 29'h37b180;
         317: out <= 29'h1343b1a3;
         318: out <= 29'hb2db197;
         319: out <= 29'hbb9b19b;
         320: out <= 29'hdc3b1a2;
         321: out <= 29'he45b1a3;
         322: out <= 29'h10ac0057;
         323: out <= 29'hdc2805b;
         324: out <= 29'h10b00040;
         325: out <= 29'h10c20061;
         326: out <= 29'h8058;
         327: out <= 29'hc4a8064;
         328: out <= 29'hc300066;
         329: out <= 29'h11040064;
         330: out <= 29'h11440065;
         331: out <= 29'h11448061;
         332: out <= 29'hb2e8056;
         333: out <= 29'hb300056;
         334: out <= 29'hbb60041;
         335: out <= 29'h11b80040;
         336: out <= 29'hc460058;
         337: out <= 29'hdb60061;
         338: out <= 29'hdb6005b;
         339: out <= 29'h380040;
         340: out <= 29'h40;
         341: out <= 29'he32005f;
         342: out <= 29'h10b8005d;
         343: out <= 29'he38805d;
         344: out <= 29'h11c4005b;
         345: out <= 29'h12460057;
         346: out <= 29'h11c68057;
         347: out <= 29'hcb2805f;
         348: out <= 29'h12b2805e;
         349: out <= 29'hcb2005e;
         350: out <= 29'h1144805b;
         351: out <= 29'h13448058;
         352: out <= 29'h11440058;
         353: out <= 29'h13b40060;
         354: out <= 29'h144e005e;
         355: out <= 29'hf4e805e;
         356: out <= 29'h13ac0040;
         357: out <= 29'h14ce0058;
         358: out <= 29'hc4e8058;
         359: out <= 29'hd348060;
         360: out <= 29'h13b4005d;
         361: out <= 29'hd34805d;
         362: out <= 29'hb2c8040;
         363: out <= 29'heac0057;
         364: out <= 29'hb2c8057;
         365: out <= 29'hbc20068;
         366: out <= 29'h15480069;
         367: out <= 29'h15ca0067;
         368: out <= 29'h164c005d;
         369: out <= 29'h16b8005e;
         370: out <= 29'h17460058;
         371: out <= 29'h17b2005a;
         372: out <= 29'h18440056;
         373: out <= 29'h18be0060;
         374: out <= 29'h19360040;
         375: out <= 29'h10c3b1a4;
         376: out <= 29'hbafb1aa;
         377: out <= 29'h1251b1a9;
         378: out <= 29'h12cbb1a6;
         379: out <= 29'h1357b1ac;
         380: out <= 29'hecfb19d;
         381: out <= 29'he39b1a3;
         382: out <= 29'h11dbb1ae;
         383: out <= 29'hc3db198;
         384: out <= 29'hcb3b1a2;
         385: out <= 29'hf5fb1b0;
         386: out <= 29'hb35b196;
         387: out <= 29'hd3fb19b;
         388: out <= 29'hde3b1b2;
         389: out <= 29'h41b180;
         390: out <= 29'hfc20066;
         391: out <= 29'hfbe005a;
         392: out <= 29'h1048005e;
         393: out <= 29'h10400040;
         394: out <= 29'hd38005a;
         395: out <= 29'h300040;
         396: out <= 29'h40;
         397: out <= 29'hc46005b;
         398: out <= 29'he000064;
         399: out <= 29'h11348061;
         400: out <= 29'h8064;
         401: out <= 29'h5d;
         402: out <= 29'h56;
         403: out <= 29'hd340061;
         404: out <= 29'hd348065;
         405: out <= 29'hd348059;
         406: out <= 29'h4c0805f;
         407: out <= 29'h4928065;
         408: out <= 29'h4920056;
         409: out <= 29'h53e0060;
         410: out <= 29'h5148057;
         411: out <= 29'h514005d;
         412: out <= 29'h5140059;
         413: out <= 29'h514805b;
         414: out <= 29'h5b80062;
         415: out <= 29'h6388062;
         416: out <= 29'h6180058;
         417: out <= 29'h6188057;
         418: out <= 29'h680005a;
         419: out <= 29'h700805a;
         420: out <= 29'h71c0058;
         421: out <= 29'h71c0057;
         422: out <= 29'h71c8066;
         423: out <= 29'h71c805e;
         default: out <= 0;
      endcase
endmodule
/*
 * Copyright 2012, Homer Hsing <homer.hsing@gmail.com>
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 * http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */

`define M     593         // M is the degree of the irreducible polynomial
`define WIDTH (2*`M-1)    // width for a GF(3^M) element
`define WIDTH_D0 1187

module tiny(clk, reset, sel, addr, w, data, out, done);
    input clk, reset;
    input sel;
    input [5:0] addr;
    input w;
    input [`WIDTH_D0:0] data;
    output [`WIDTH_D0:0] out;
    output done;

    /* for FSM */
    wire [5:0] fsm_addr;
    /* for RAM */
    wire [5:0] ram_a_addr, ram_b_addr;
    wire [`WIDTH_D0:0] ram_b_data_in;
    wire ram_a_w, ram_b_w;
    wire [`WIDTH_D0:0] ram_a_data_out, ram_b_data_out;
    /* for const */
    wire [`WIDTH_D0:0] const0_out, const1_out;
    wire const0_effective, const1_effective;
    /* for muxer */
    wire [`WIDTH_D0:0] muxer0_out, muxer1_out;
    /* for ROM */
    wire [8:0] rom_addr;
    wire [28:0] rom_q;
    /* for PE */
    wire [10:0] pe_ctrl;
    
    assign out = ram_a_data_out;
    
    select 
        select0 (sel, addr, fsm_addr, w, ram_a_addr, ram_a_w);
    rom
        rom0 (clk, rom_addr, rom_q);
    FSM
        fsm0 (clk, reset, rom_addr, rom_q, fsm_addr, ram_b_addr, ram_b_w, pe_ctrl, done);
    const_
        const0 (clk, ram_a_addr, const0_out, const0_effective),
        const1 (clk, ram_b_addr, const1_out, const1_effective);
    ram
        ram0 (clk, ram_a_w, ram_a_addr, data, ram_a_data_out, ram_b_w, ram_b_addr[5:0], ram_b_data_in, ram_b_data_out);
    muxer
        muxer0 (ram_a_data_out, const0_out, const0_effective, muxer0_out),
        muxer1 (ram_b_data_out, const1_out, const1_effective, muxer1_out);
    PE
        pe0 (clk, reset, pe_ctrl, muxer1_out, muxer0_out[`WIDTH:0], muxer0_out[`WIDTH:0], ram_b_data_in[`WIDTH:0]);
    
    assign ram_b_data_in[`WIDTH_D0:`WIDTH+1] = 0;
endmodule

module select(sel, addr_in, addr_fsm_in, w_in, addr_out, w_out);
    input sel;
    input [5:0] addr_in;
    input [5:0] addr_fsm_in;
    input w_in;
    output [5:0] addr_out;
    output w_out;
    
    assign addr_out = sel ? addr_in : addr_fsm_in;
    assign w_out = sel & w_in;
endmodule

module muxer(from_ram, from_const, const_effective, out);
    input [`WIDTH_D0:0] from_ram, from_const;
    input const_effective;
    output [`WIDTH_D0:0] out;
    
    assign out = const_effective ? from_const : from_ram;
endmodule
