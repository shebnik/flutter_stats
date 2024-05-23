import 'package:distributions/distributions.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class Fisher {
  static Future<double> inv({
    required double alpha,
    required int df1,
    required int df2,
  }) async {
    double? result;
    try {
      result = await Distributions.inv(
        alpha: alpha,
        df1: df1,
        df2: df2,
      );
    } on PlatformException catch (e) {
      debugPrint('Failed to get result: ${e.message}');
    }
    if (result != null) return result;

    final n = df2;
    if (n < 1) {
      throw Exception('n must be greater than 0');
    }
    if (n > fppf.length + 1) {
      return 3;
    }
    return fppf[n - 1];
  }

  // auto calculated 1000 values with alpha = 0.05 and df1 = 2
  static const List<double> fppf = [
    199.5,
    19,
    9.552094496,
    6.94427191,
    5.786135043,
    5.14325285,
    4.737414128,
    4.458970108,
    4.256494729,
    4.102821015,
    3.982297957,
    3.885293835,
    3.805565253,
    3.738891832,
    3.682320344,
    3.633723468,
    3.591530568,
    3.554557146,
    3.521893261,
    3.492828477,
    3.466800112,
    3.443356779,
    3.422132208,
    3.402826105,
    3.385189961,
    3.369016359,
    3.354130829,
    3.340385558,
    3.327654499,
    3.315829501,
    3.304817252,
    3.294536816,
    3.284917651,
    3.275897991,
    3.267423525,
    3.259446306,
    3.251923846,
    3.244818361,
    3.238096135,
    3.231726993,
    3.225683842,
    3.219942293,
    3.214480328,
    3.20927802,
    3.204317292,
    3.199581706,
    3.195056281,
    3.190727336,
    3.186582352,
    3.182609852,
    3.178799292,
    3.175140971,
    3.171625948,
    3.168245967,
    3.164993396,
    3.161861165,
    3.158842719,
    3.155931971,
    3.153123258,
    3.150411311,
    3.147791213,
    3.145258377,
    3.142808517,
    3.140437622,
    3.138141935,
    3.135917934,
    3.133762315,
    3.131671971,
    3.129643983,
    3.127675601,
    3.125764237,
    3.123907449,
    3.122102932,
    3.120348511,
    3.118642128,
    3.116981837,
    3.115365797,
    3.11379226,
    3.112259573,
    3.110766166,
    3.109310547,
    3.107891302,
    3.106507082,
    3.105156608,
    3.103838661,
    3.102552079,
    3.101295757,
    3.100068639,
    3.098869718,
    3.097698035,
    3.096552671,
    3.09543275,
    3.094337433,
    3.093265919,
    3.092217439,
    3.091191259,
    3.090186675,
    3.089203013,
    3.088239626,
    3.087295893,
    3.086371219,
    3.085465033,
    3.084576785,
    3.083705948,
    3.082852016,
    3.082014501,
    3.081192934,
    3.080386863,
    3.079595855,
    3.078819492,
    3.078057369,
    3.0773091,
    3.076574309,
    3.075852636,
    3.075143733,
    3.074447264,
    3.073762904,
    3.073090341,
    3.072429272,
    3.071779405,
    3.071140457,
    3.070512156,
    3.069894238,
    3.069286447,
    3.068688537,
    3.068100269,
    3.067521411,
    3.066951739,
    3.066391037,
    3.065839094,
    3.065295706,
    3.064760677,
    3.064233814,
    3.063714933,
    3.063203853,
    3.062700399,
    3.062204403,
    3.0617157,
    3.061234129,
    3.060759537,
    3.060291772,
    3.059830689,
    3.059376144,
    3.058928001,
    3.058486124,
    3.058050383,
    3.057620652,
    3.057196806,
    3.056778726,
    3.056366295,
    3.055959399,
    3.055557928,
    3.055161773,
    3.05477083,
    3.054384997,
    3.054004174,
    3.053628264,
    3.053257172,
    3.052890808,
    3.05252908,
    3.052171902,
    3.051819187,
    3.051470854,
    3.051126821,
    3.050787008,
    3.050451339,
    3.050119738,
    3.049792131,
    3.049468448,
    3.049148618,
    3.048832572,
    3.048520244,
    3.048211568,
    3.047906481,
    3.047604921,
    3.047306827,
    3.047012139,
    3.046720799,
    3.046432751,
    3.046147939,
    3.045866309,
    3.045587808,
    3.045312384,
    3.045039987,
    3.044770566,
    3.044504073,
    3.044240461,
    3.043979683,
    3.043721694,
    3.043466449,
    3.043213905,
    3.042964019,
    3.04271675,
    3.042472056,
    3.042229897,
    3.041990235,
    3.04175303,
    3.041518246,
    3.041285845,
    3.041055791,
    3.040828049,
    3.040602585,
    3.040379364,
    3.040158352,
    3.039939518,
    3.039722829,
    3.039508254,
    3.039295762,
    3.039085323,
    3.038876907,
    3.038670486,
    3.03846603,
    3.038263512,
    3.038062905,
    3.037864181,
    3.037667314,
    3.037472278,
    3.037279048,
    3.037087599,
    3.036897906,
    3.036709945,
    3.036523693,
    3.036339126,
    3.036156222,
    3.035974958,
    3.035795313,
    3.035617264,
    3.035440791,
    3.035265872,
    3.035092488,
    3.034920618,
    3.034750242,
    3.034581342,
    3.034413897,
    3.03424789,
    3.034083301,
    3.033920113,
    3.033758308,
    3.033597868,
    3.033438776,
    3.033281016,
    3.03312457,
    3.032969422,
    3.032815557,
    3.032662958,
    3.032511609,
    3.032361496,
    3.032212603,
    3.032064916,
    3.03191842,
    3.0317731,
    3.031628943,
    3.031485935,
    3.031344061,
    3.031203309,
    3.031063665,
    3.030925117,
    3.03078765,
    3.030651254,
    3.030515914,
    3.03038162,
    3.030248358,
    3.030116118,
    3.029984887,
    3.029854654,
    3.029725408,
    3.029597137,
    3.029469831,
    3.029343477,
    3.029218067,
    3.02909359,
    3.028970034,
    3.02884739,
    3.028725648,
    3.028604797,
    3.028484829,
    3.028365733,
    3.0282475,
    3.028130121,
    3.028013586,
    3.027897887,
    3.027783013,
    3.027668958,
    3.027555711,
    3.027443265,
    3.02733161,
    3.027220739,
    3.027110643,
    3.027001315,
    3.026892745,
    3.026784927,
    3.026677853,
    3.026571514,
    3.026465904,
    3.026361014,
    3.026256838,
    3.026153369,
    3.026050598,
    3.025948519,
    3.025847126,
    3.02574641,
    3.025646366,
    3.025546987,
    3.025448266,
    3.025350196,
    3.025252772,
    3.025155986,
    3.025059833,
    3.024964307,
    3.024869401,
    3.024775108,
    3.024681425,
    3.024588343,
    3.024495859,
    3.024403965,
    3.024312656,
    3.024221928,
    3.024131773,
    3.024042187,
    3.023953165,
    3.023864701,
    3.02377679,
    3.023689426,
    3.023602605,
    3.023516321,
    3.023430571,
    3.023345347,
    3.023260647,
    3.023176465,
    3.023092796,
    3.023009635,
    3.022926979,
    3.022844822,
    3.02276316,
    3.022681988,
    3.022601302,
    3.022521098,
    3.022441372,
    3.022362118,
    3.022283334,
    3.022205014,
    3.022127155,
    3.022049753,
    3.021972803,
    3.021896302,
    3.021820246,
    3.02174463,
    3.021669452,
    3.021594707,
    3.021520391,
    3.021446502,
    3.021373034,
    3.021299985,
    3.021227351,
    3.021155129,
    3.021083315,
    3.021011905,
    3.020940897,
    3.020870286,
    3.02080007,
    3.020730245,
    3.020660807,
    3.020591755,
    3.020523084,
    3.020454791,
    3.020386874,
    3.020319328,
    3.020252152,
    3.020185342,
    3.020118895,
    3.020052808,
    3.019987078,
    3.019921703,
    3.019856679,
    3.019792004,
    3.019727674,
    3.019663688,
    3.019600042,
    3.019536734,
    3.01947376,
    3.019411119,
    3.019348808,
    3.019286823,
    3.019225163,
    3.019163826,
    3.019102807,
    3.019042106,
    3.018981719,
    3.018921644,
    3.018861879,
    3.018802421,
    3.018743268,
    3.018684417,
    3.018625867,
    3.018567615,
    3.018509658,
    3.018451995,
    3.018394623,
    3.018337541,
    3.018280744,
    3.018224233,
    3.018168004,
    3.018112056,
    3.018056386,
    3.018000992,
    3.017945873,
    3.017891025,
    3.017836448,
    3.017782139,
    3.017728096,
    3.017674318,
    3.017620802,
    3.017567546,
    3.017514549,
    3.017461808,
    3.017409322,
    3.017357089,
    3.017305108,
    3.017253375,
    3.01720189,
    3.017150651,
    3.017099656,
    3.017048903,
    3.01699839,
    3.016948117,
    3.01689808,
    3.016848279,
    3.016798712,
    3.016749377,
    3.016700272,
    3.016651397,
    3.016602749,
    3.016554326,
    3.016506128,
    3.016458152,
    3.016410397,
    3.016362862,
    3.016315545,
    3.016268445,
    3.016221559,
    3.016174887,
    3.016128428,
    3.016082179,
    3.016036139,
    3.015990307,
    3.015944681,
    3.015899261,
    3.015854044,
    3.01580903,
    3.015764216,
    3.015719603,
    3.015675187,
    3.015630968,
    3.015586945,
    3.015543117,
    3.015499481,
    3.015456038,
    3.015412784,
    3.015369721,
    3.015326845,
    3.015284156,
    3.015241652,
    3.015199333,
    3.015157197,
    3.015115244,
    3.015073471,
    3.015031877,
    3.014990462,
    3.014949225,
    3.014908164,
    3.014867278,
    3.014826565,
    3.014786026,
    3.014745659,
    3.014705462,
    3.014665435,
    3.014625576,
    3.014585885,
    3.01454636,
    3.014507,
    3.014467805,
    3.014428773,
    3.014389904,
    3.014351196,
    3.014312648,
    3.014274259,
    3.014236029,
    3.014197956,
    3.014160039,
    3.014122278,
    3.014084671,
    3.014047218,
    3.014009917,
    3.013972768,
    3.013935769,
    3.013898921,
    3.013862221,
    3.013825669,
    3.013789264,
    3.013753006,
    3.013716893,
    3.013680924,
    3.013645099,
    3.013609416,
    3.013573876,
    3.013538476,
    3.013503217,
    3.013468097,
    3.013433115,
    3.013398272,
    3.013363565,
    3.013328994,
    3.013294559,
    3.013260258,
    3.013226091,
    3.013192056,
    3.013158154,
    3.013124384,
    3.013090744,
    3.013057234,
    3.013023853,
    3.0129906,
    3.012957475,
    3.012924477,
    3.012891605,
    3.012858859,
    3.012826237,
    3.012793739,
    3.012761365,
    3.012729114,
    3.012696984,
    3.012664975,
    3.012633087,
    3.012601319,
    3.01256967,
    3.01253814,
    3.012506728,
    3.012475432,
    3.012444254,
    3.012413191,
    3.012382243,
    3.012351411,
    3.012320692,
    3.012290086,
    3.012259593,
    3.012229212,
    3.012198943,
    3.012168785,
    3.012138737,
    3.012108798,
    3.012078969,
    3.012049248,
    3.012019635,
    3.011990129,
    3.01196073,
    3.011931437,
    3.01190225,
    3.011873168,
    3.01184419,
    3.011815316,
    3.011786545,
    3.011757877,
    3.011729311,
    3.011700847,
    3.011672484,
    3.011644221,
    3.011616059,
    3.011587996,
    3.011560032,
    3.011532167,
    3.011504399,
    3.011476729,
    3.011449156,
    3.011421679,
    3.011394298,
    3.011367013,
    3.011339822,
    3.011312726,
    3.011285724,
    3.011258815,
    3.011231999,
    3.011205276,
    3.011178644,
    3.011152105,
    3.011125656,
    3.011099297,
    3.011073029,
    3.011046851,
    3.011020762,
    3.010994761,
    3.010968849,
    3.010943024,
    3.010917287,
    3.010891637,
    3.010866074,
    3.010840596,
    3.010815204,
    3.010789898,
    3.010764676,
    3.010739538,
    3.010714484,
    3.010689514,
    3.010664627,
    3.010639823,
    3.010615101,
    3.010590461,
    3.010565902,
    3.010541424,
    3.010517027,
    3.010492711,
    3.010468474,
    3.010444316,
    3.010420238,
    3.010396238,
    3.010372317,
    3.010348473,
    3.010324707,
    3.010301018,
    3.010277406,
    3.010253871,
    3.010230411,
    3.010207028,
    3.010183719,
    3.010160485,
    3.010137326,
    3.010114242,
    3.010091231,
    3.010068293,
    3.010045429,
    3.010022638,
    3.009999919,
    3.009977272,
    3.009954697,
    3.009932193,
    3.009909761,
    3.009887399,
    3.009865107,
    3.009842886,
    3.009820735,
    3.009798653,
    3.00977664,
    3.009754696,
    3.00973282,
    3.009711013,
    3.009689273,
    3.009667601,
    3.009645996,
    3.009624458,
    3.009602986,
    3.009581581,
    3.009560242,
    3.009538968,
    3.00951776,
    3.009496617,
    3.009475538,
    3.009454524,
    3.009433574,
    3.009412688,
    3.009391866,
    3.009371107,
    3.009350411,
    3.009329778,
    3.009309207,
    3.009288698,
    3.009268251,
    3.009247866,
    3.009227542,
    3.009207279,
    3.009187076,
    3.009166935,
    3.009146853,
    3.009126832,
    3.00910687,
    3.009086967,
    3.009067124,
    3.009047339,
    3.009027613,
    3.009007946,
    3.008988337,
    3.008968785,
    3.008949291,
    3.008929854,
    3.008910475,
    3.008891152,
    3.008871886,
    3.008852676,
    3.008833523,
    3.008814425,
    3.008795382,
    3.008776395,
    3.008757464,
    3.008738587,
    3.008719764,
    3.008700997,
    3.008682283,
    3.008663623,
    3.008645017,
    3.008626464,
    3.008607965,
    3.008589518,
    3.008571125,
    3.008552784,
    3.008534495,
    3.008516258,
    3.008498074,
    3.008479941,
    3.008461859,
    3.008443828,
    3.008425849,
    3.00840792,
    3.008390042,
    3.008372215,
    3.008354437,
    3.008336709,
    3.008319032,
    3.008301403,
    3.008283824,
    3.008266294,
    3.008248813,
    3.008231381,
    3.008213997,
    3.008196661,
    3.008179374,
    3.008162134,
    3.008144942,
    3.008127798,
    3.008110701,
    3.008093651,
    3.008076647,
    3.008059691,
    3.008042781,
    3.008025918,
    3.0080091,
    3.007992329,
    3.007975603,
    3.007958923,
    3.007942288,
    3.007925698,
    3.007909154,
    3.007892654,
    3.007876199,
    3.007859788,
    3.007843422,
    3.0078271,
    3.007810822,
    3.007794587,
    3.007778396,
    3.007762249,
    3.007746145,
    3.007730083,
    3.007714065,
    3.007698089,
    3.007682156,
    3.007666266,
    3.007650417,
    3.007634611,
    3.007618846,
    3.007603123,
    3.007587442,
    3.007571802,
    3.007556203,
    3.007540646,
    3.007525129,
    3.007509653,
    3.007494217,
    3.007478822,
    3.007463467,
    3.007448153,
    3.007432878,
    3.007417643,
    3.007402447,
    3.007387291,
    3.007372175,
    3.007357097,
    3.007342059,
    3.007327059,
    3.007312098,
    3.007297176,
    3.007282292,
    3.007267446,
    3.007252639,
    3.007237869,
    3.007223137,
    3.007208443,
    3.007193787,
    3.007179167,
    3.007164585,
    3.007150041,
    3.007135533,
    3.007121062,
    3.007106627,
    3.00709223,
    3.007077868,
    3.007063543,
    3.007049254,
    3.007035001,
    3.007020784,
    3.007006602,
    3.006992456,
    3.006978346,
    3.006964271,
    3.006950231,
    3.006936226,
    3.006922256,
    3.006908321,
    3.006894421,
    3.006880555,
    3.006866723,
    3.006852926,
    3.006839163,
    3.006825434,
    3.006811739,
    3.006798077,
    3.006784449,
    3.006770855,
    3.006757294,
    3.006743767,
    3.006730273,
    3.006716811,
    3.006703383,
    3.006689987,
    3.006676624,
    3.006663294,
    3.006649996,
    3.00663673,
    3.006623497,
    3.006610295,
    3.006597126,
    3.006583988,
    3.006570882,
    3.006557808,
    3.006544765,
    3.006531754,
    3.006518774,
    3.006505825,
    3.006492907,
    3.00648002,
    3.006467164,
    3.006454339,
    3.006441544,
    3.00642878,
    3.006416046,
    3.006403342,
    3.006390669,
    3.006378026,
    3.006365412,
    3.006352829,
    3.006340275,
    3.006327751,
    3.006315256,
    3.006302791,
    3.006290355,
    3.006277949,
    3.006265571,
    3.006253223,
    3.006240903,
    3.006228612,
    3.00621635,
    3.006204117,
    3.006191912,
    3.006179736,
    3.006167588,
    3.006155468,
    3.006143376,
    3.006131312,
    3.006119276,
    3.006107268,
    3.006095288,
    3.006083335,
    3.00607141,
    3.006059512,
    3.006047642,
    3.006035799,
    3.006023983,
    3.006012194,
    3.006000433,
    3.005988698,
    3.005976989,
    3.005965308,
    3.005953653,
    3.005942025,
    3.005930423,
    3.005918847,
    3.005907298,
    3.005895775,
    3.005884278,
    3.005872806,
    3.005861361,
    3.005849942,
    3.005838548,
    3.00582718,
    3.005815837,
    3.00580452,
    3.005793229,
    3.005781962,
    3.005770721,
    3.005759505,
    3.005748314,
    3.005737148,
    3.005726007,
    3.00571489,
    3.005703799,
    3.005692731,
    3.005681689,
    3.005670671,
    3.005659677,
    3.005648708,
    3.005637762,
    3.005626841,
    3.005615944,
    3.005605071,
    3.005594222,
    3.005583397,
    3.005572595,
    3.005561817,
    3.005551063,
    3.005540332,
    3.005529624,
    3.00551894,
    3.005508279,
    3.005497642,
    3.005487027,
    3.005476436,
    3.005465868,
    3.005455322,
    3.005444799,
    3.005434299,
    3.005423822,
    3.005413367,
    3.005402935,
    3.005392525,
    3.005382138,
    3.005371773,
    3.00536143,
    3.00535111,
    3.005340811,
    3.005330535,
    3.00532028,
    3.005310048,
    3.005299837,
    3.005289648,
    3.005279481,
    3.005269335,
    3.005259211,
    3.005249108,
    3.005239027,
    3.005228966,
    3.005218928,
    3.00520891,
    3.005198914,
    3.005188938,
    3.005178984,
    3.005169051,
    3.005159138,
    3.005149247,
    3.005139376,
    3.005129525,
    3.005119695,
    3.005109886,
    3.005100098,
    3.005090329,
    3.005080581,
    3.005070854,
    3.005061146,
    3.005051459,
    3.005041792,
    3.005032145,
    3.005022518,
    3.00501291,
    3.005003323,
    3.004993755,
    3.004984208,
    3.004974679,
    3.004965171,
    3.004955682,
    3.004946212,
    3.004936762,
    3.004927331,
    3.00491792,
    3.004908528,
    3.004899155,
    3.004889801,
    3.004880466,
    3.00487115,
    3.004861853,
    3.004852575,
    3.004843316,
    3.004834076,
    3.004824854,
    3.004815651,
    3.004806467,
    3.004797301,
    3.004788153,
    3.004779025,
    3.004769914,
    3.004760822,
    3.004751748,
    3.004742692,
    3.004733655,
    3.004724636,
  ];
}
