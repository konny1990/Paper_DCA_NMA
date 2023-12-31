########################################################################
#################     Script for estimating the NB  ####################
#######                       Under strategies:          ######################
#####   Treat none, treat all with N, treat all with DF, ############
#####     Treat all with GA, and treat based on the model  ##########
################ for a range of thresholds for    #######################
##################     T_DF=T_GA and T_N    ###################3
################ & Creation of relevant Plot  ################################
##################################################################################3



#Entire ADdataset
RiskData$outcome<-RiskData$RELAPSE2year
n_studies<-c(nrow(RiskData[which(RiskData$STUDYID==1 & RiskData$TRT01A==1),]),nrow(RiskData[which(RiskData$STUDYID==1 & RiskData$TRT01A==4),]),
             nrow(RiskData[which(RiskData$STUDYID==2 & RiskData$TRT01A==1),]),nrow(RiskData[which(RiskData$STUDYID==2 & RiskData$TRT01A==2),]),
             nrow(RiskData[which(RiskData$STUDYID==2 & RiskData$TRT01A==4),]),nrow(RiskData[which(RiskData$STUDYID==3 & RiskData$TRT01A==3),]),
             nrow(RiskData[which(RiskData$STUDYID==3 & RiskData$TRT01A==4),]))

n_events<-c(nrow(RiskData[which(RiskData$STUDYID==1 & RiskData$TRT01A==1 & RiskData$outcome==1),]), nrow(RiskData[which(RiskData$STUDYID==1 & RiskData$TRT01A==4 & RiskData$outcome==1),]),
            nrow(RiskData[which(RiskData$STUDYID==2 & RiskData$TRT01A==1 & RiskData$outcome==1),]), nrow(RiskData[which(RiskData$STUDYID==2 & RiskData$TRT01A==2 & RiskData$outcome==1),]),
            nrow(RiskData[which(RiskData$STUDYID==2 & RiskData$TRT01A==4 & RiskData$outcome==1),]), nrow(RiskData[which(RiskData$STUDYID==3 & RiskData$TRT01A==3 & RiskData$outcome==1),]),
            nrow(RiskData[which(RiskData$STUDYID==3 & RiskData$TRT01A==4 & RiskData$outcome==1),]))


dataAD_Whole<-cbind(c(1,1,2,2,2,3,3),c(1,4,1,2,4,3,4),n_studies, n_events)
dataAD_Whole<-as.data.frame(dataAD_Whole)
colnames(dataAD_Whole)<-c("St","Dr","N_ran","N_rel")
dataAD_Whole_Pl<-dataAD_Whole[which(dataAD_Whole$Dr==4),]

## event rate in placebo arm in the whole dataset
m1<-metaprop(N_rel,N_ran,data=dataAD_Whole_Pl,sm="PLOGIT" )
#network meta-analysis in the whole dataset
TestPair <- pairwise(treat=Dr, event=N_rel, n=N_ran, data=dataAD_Whole, sm="RR", studlab=St, allstudies = TRUE)

net1 <- netmeta(TE, seTE, treat1, treat2, studlab, data = TestPair, sm = "RR", comb.random=F, comb.fixed=T, prediction=TRUE, ref=4)


# CREATING DATAFRAME THAT IS ONE LINE PER THRESHOLD PER all default STRATEGIES
### Values for the range of threshold probabilities
xstart=0.01
xstop=1.00
xby=0.01

# CREATING DATAFRAME THAT IS ONE LINE PER THRESHOLD PER all default STRATEGIES
nb=data.frame(rep(seq(from=xstart, to=xstop, by=xby), times=21, each=21))
names(nb)="threshold1"
nb["threshold2"]=rep(seq(from=0.05, to=0.25, by=xby),times=100)


##Estimation of the NB under "treat none" strategy
nb["Placebo"]=0

##Estimation of the NB under "treat all with Natalizumab" strategy using the corresponding threshold values
nb["Natalizumab"]<-(expit(m1$TE.fixed)-expit(m1$TE.fixed)*exp(net1$TE.fixed)[3,4])-nb$threshold1
##Estimation of the NB under "treat all with DF" strategy using the corresponding threshold values
nb["Dimethyl FUmerate"]<-(expit(m1$TE.fixed)-expit(m1$TE.fixed)*exp(net1$TE.fixed)[1,4])-nb$threshold2
##Estimation of the NB under "treat all with GA" strategy using the corresponding threshold values
nb["Glatiramer Acetate"]<-(expit(m1$TE.fixed)-expit(m1$TE.fixed)*exp(net1$TE.fixed)[2,4])-nb$threshold2


##Estimation of the NB under "treat based on the model" strategy
nb["Model"]<-NA
nb["max"]<-NA
nb["BestApproach"]<-NA

for (t in 379:840){
  #Rule for recommended treatment
  ##Let's say we use as a threshold T=15%. If a patient has a RD>15% the will be prescribed to the drug with the maximum risk difference
  ##minimum f predicted prbability - the treatment that the model recommends
  RiskData$maxRDTh<-NA
  RiskData$RecommendedTreatmentThreshold<-NA
  for (i in 1:nrow(RiskData)){
    RiskData$maxRDTh[i]<-max(RiskData$RDDF[i]-nb$threshold2[t],RiskData$RDGA[i]-nb$threshold2[t],RiskData$RDN[i]-nb$threshold1[t],0)
    RiskData$RecommendedTreatmentThreshold[i]<-which.max(c(RiskData$RDDF[i]-nb$threshold2[t],RiskData$RDGA[i]-nb$threshold2[t],RiskData$RDN[i]-nb$threshold1[t],0))
  }


  RiskDataCongruent<-RiskData[which(RiskData$Treatment==RiskData$RecommendedTreatmentThreshold),]
  n_study1T1<-nrow(RiskDataCongruent[which(RiskDataCongruent$STUDYID==1 & RiskDataCongruent$TRT01A==1),])
  n_study1T4<-nrow(RiskDataCongruent[which(RiskDataCongruent$STUDYID==1 & RiskDataCongruent$TRT01A==4),])
  n_study2T1<-nrow(RiskDataCongruent[which(RiskDataCongruent$STUDYID==2 & RiskDataCongruent$TRT01A==1),])
  n_study2T2<-nrow(RiskDataCongruent[which(RiskDataCongruent$STUDYID==2 & RiskDataCongruent$TRT01A==2),])
  n_study2T4<-nrow(RiskDataCongruent[which(RiskDataCongruent$STUDYID==2 & RiskDataCongruent$TRT01A==4),])
  n_study3T3<-nrow(RiskDataCongruent[which(RiskDataCongruent$STUDYID==3 & RiskDataCongruent$TRT01A==3),])
  n_study3T4<-nrow(RiskDataCongruent[which(RiskDataCongruent$STUDYID==3 & RiskDataCongruent$TRT01A==4),])
  r_study1T1<-nrow(RiskDataCongruent[which(RiskDataCongruent$STUDYID==1 & RiskDataCongruent$TRT01A==1 & RiskDataCongruent$outcome==1),])
  r_study1T4<-nrow(RiskDataCongruent[which(RiskDataCongruent$STUDYID==1 & RiskDataCongruent$TRT01A==4 & RiskDataCongruent$outcome==1),])
  r_study2T1<-nrow(RiskDataCongruent[which(RiskDataCongruent$STUDYID==2 & RiskDataCongruent$TRT01A==1 & RiskDataCongruent$outcome==1),])
  r_study2T2<-nrow(RiskDataCongruent[which(RiskDataCongruent$STUDYID==2 & RiskDataCongruent$TRT01A==2 & RiskDataCongruent$outcome==1),])
  r_study2T4<-nrow(RiskDataCongruent[which(RiskDataCongruent$STUDYID==2 & RiskDataCongruent$TRT01A==4 & RiskDataCongruent$outcome==1),])
  r_study3T3<-nrow(RiskDataCongruent[which(RiskDataCongruent$STUDYID==3 & RiskDataCongruent$TRT01A==3 & RiskDataCongruent$outcome==1),])
  r_study3T4<-nrow(RiskDataCongruent[which(RiskDataCongruent$STUDYID==3 & RiskDataCongruent$TRT01A==4 & RiskDataCongruent$outcome==1),])
  dataAD_Congruent<-cbind(c(1,1,2,2,2,3,3),c(1,4,1,2,4,3,4),c(n_study1T1,n_study1T4,n_study2T1,n_study2T2,n_study2T4,n_study3T3,n_study3T4),
                          c(r_study1T1,r_study1T4,r_study2T1,r_study2T2,r_study2T4,r_study3T3,r_study3T4))

  dataAD_Congruent<-as.data.frame(dataAD_Congruent)
  colnames(dataAD_Congruent)<-c("St","Dr","N_ran","N_rel")

  dataAD_Congruent_Pl<-dataAD_Congruent[which(dataAD_Congruent$Dr==4 & dataAD_Congruent$N_ran!=0 ),]
  ## event rate in placebo arm in the congruent dataset
  m2<-metaprop(N_rel,N_ran,data=dataAD_Congruent_Pl,sm="PLOGIT" )

  #network meta-analysis in the congruent dataset
  TestPair <- pairwise(treat=Dr, event=N_rel, n=N_ran, data=dataAD_Congruent, sm="RR", studlab=St, allstudies = TRUE)
  net2 <- netmeta(TE, seTE, treat1, treat2, studlab, data = TestPair, sm = "RR", comb.random=F, comb.fixed=T, prediction=TRUE, ref=4)

  n_total<-nrow(RiskDataCongruent)
  n_pl<-nrow(RiskDataCongruent[which(RiskDataCongruent$Treatment==4),])
  n_N<-nrow(RiskDataCongruent[which(RiskDataCongruent$Treatment==3),])
  n_DF<-nrow(RiskDataCongruent[which(RiskDataCongruent$Treatment==1),])
  n_GA<-nrow(RiskDataCongruent[which(RiskDataCongruent$Treatment==2),])

  if (n_N!=0) {
    e_N<-n_N*expit(m2$TE.fixed)* exp(net2$TE.nma.fixed[which(net2$treat1==3)])
  }
  if (n_N==0) {
    e_N<-0
  }
  if (n_DF!=0 && nrow(dataAD_Congruent[which(dataAD_Congruent$Dr==4 & dataAD_Congruent$N_ran!=0 ),])!=0  ) {
    e_DF<-n_DF*expit(m2$TE.fixed)* exp(net2$TE.nma.fixed[which(net2$treat1==1)])
    e_DF<-unique(e_DF)
  }

  if (n_DF!=0 && nrow(dataAD_Congruent[which(dataAD_Congruent$Dr==4 & dataAD_Congruent$N_ran==0 ),])!=0  ) {
    e_DF<-n_DF*expit(m2$TE.fixed)
  }
  if (n_DF==0) {
    e_DF<-0
  }
  if (n_GA!=0) {
    e_GA<-n_GA*expit(m2$TE.fixed)* exp(net2$TE.nma.fixed[which(net2$treat1==2)])
  }
  if (n_GA==0) {
    e_GA<-0
  }

  if (n_pl!=0) {
    e_pl<-n_pl*expit(m2$TE.fixed)
  }
  if (n_pl==0) {
    e_pl<-0
  }

  e_total<- ( e_pl + e_N + e_DF + e_GA)/n_total

  nb[t,7]<-(expit(m1$TE.fixed)-e_total)-((n_N*nb$threshold1[t]+n_DF*nb$threshold2[t]+n_GA*nb$threshold2[t])/n_total)
  nb[t,8]<-max(nb$Placebo[t],nb$Natalizumab[t],nb$`Dimethyl FUmerate`[t],nb$`Glatiramer Acetate`[t],nb$Model[t])
  nb[t,9]<-which.max(c(nb$Placebo[t],nb$Natalizumab[t],nb$`Dimethyl FUmerate`[t],nb$`Glatiramer Acetate`[t],nb$Model[t]))
  
}



nb$dif<-round(nb[,8]-nb[,7],3)
#dataNeeded$BestApproach[which(dataNeeded$dif<=0.002)]<-5

nb$second<-NA

for (i in 379:840){
if (nb$BestApproach[i]==5){
  nb$second[i]<-max(nb$Placebo[i],nb$Natalizumab[i],nb$`Dimethyl FUmerate`[i],nb$`Glatiramer Acetate`[i])
  nb$dif[i]<-round(nb$max[i]-nb$second[i],3)}
  else {nb$dif[i]<-nb$dif[i]}
}

#nb[450:840,]

dataNeeded<-nb[379:840,c(1,2,9,10)]
dataNeeded$BestApproach[which(dataNeeded$dif<=0.0005)]<-5
dataNeeded$dif<-dataNeeded$dif*100
#for(i in 1:nrow(dataNeeded)){
#if (dataNeeded$threshold1[i]<dataNeeded$threshold2[i]){
#  dataNeeded$BestApproach[i]<-6
#}
#}
Plot_Threshold_Ranges<-ggplot(dataNeeded, aes(x=threshold1, y=threshold2, fill= BestApproach, weight=5)) +
  geom_tile() +
  geom_text(aes(label = dif))+
  scale_fill_distiller(palette = "Spectral") +
  theme_classic2()



##dataNeeded$BestApproach[which(dataNeeded$dif<=0.01)]<-5
##Plot_Threshold_Ranges<-ggplot(dataNeeded, aes(x=threshold1, y=threshold2, fill= BestApproach, weight=5)) +
 ## geom_tile() +
  ##scale_fill_distiller(palette = "Spectral") +
  #theme_classic2()

#dataNeeded$BestApproach[which(dataNeeded$dif<=0.002)]<-5
#Plot_Threshold_Ranges<-ggplot(dataNeeded, aes(x=threshold1, y=threshold2, fill= BestApproach, weight=5)) +
 # geom_tile() +
  #scale_fill_distiller(palette = "Spectral") +
  #theme_classic2()
