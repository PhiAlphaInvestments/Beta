//+------------------------------------------------------------------+
//|                                                         Beta.mq4 |
//|                                                      WJBOSS INC. |
//|                                                             None |
//+------------------------------------------------------------------+
#property copyright   "2005-2014, MetaQuotes Software Corp."
#property link        "http://www.mql4.com"
#property description "Var"
#property strict








//--- indicator settings
#property  indicator_separate_window
#property  indicator_buffers 1
#property  indicator_color1  Red
#property  indicator_width1  1
#property  indicator_maximum 1.5
#property  indicator_minimum -1.5
//--- indicator parameters




input int InpDepthOfMarket=20;   // Fast EMA Period
input string MarketX  = "EURUSD";
input string MarketY  = "EURUSD";
input ENUM_TIMEFRAMES TF = PERIOD_M1;
double    ExtSignalBuffer[];
//--- right input parameters flag
bool      ExtParameters=false;
int OnInit()
  {
//--- indicator buffers mapping
      IndicatorDigits(Digits+1);
//--- drawing settings
   SetIndexStyle(0,DRAW_LINE);
   ;
   SetIndexDrawBegin(0,InpDepthOfMarket);
//--- indicator buffers mapping
   
   SetIndexBuffer(0,ExtSignalBuffer);
//--- name for DataWindow and indicator subwindow label
   IndicatorShortName("Beta("+IntegerToString(InpDepthOfMarket)+")"+" "+MarketX+"->"+MarketY);
   SetIndexLabel(0,"Beta");
   //--- check for input parameters
   if(InpDepthOfMarket<=10  )
     {
      Print("Wrong input parameters");
      ExtParameters=false;
      return(INIT_FAILED);
     }
   else
      ExtParameters=true;
//--- initialization done
//---
   return(INIT_SUCCEEDED);
  }
//+------------------------------------------------------------------+
//| Custom indicator iteration function                              |
//+------------------------------------------------------------------+
int OnCalculate(const int rates_total,
                const int prev_calculated,
                const datetime &time[],
                const double &open[],
                const double &high[],
                const double &low[],
                const double &close[],
                const long &tick_volume[],
                const long &volume[],
                const int &spread[])
  {
//---
      int i,limit;
//---
   if(rates_total<=InpDepthOfMarket+1|| !ExtParameters)
      return(0);
//--- last counted bar will be recounted
   limit=rates_total-prev_calculated;
   if(prev_calculated>0)
      limit++;
//--- macd counted in the 1-st buffer
   //Print(Cov(MarketX,MarketY)/Var(MarketY));
   for(i=0; i<limit; i++)
      ExtSignalBuffer[i]= Cov(MarketX,MarketY)/Var(MarketY);
      
//--- signal line counted in the 2-nd buffer
   //SimpleMAOnBuffer(rates_total,prev_calculated,0,InpSignalSMA,ExtMacdBuffer,ExtSignalBuffer);
   
//--- done

//--- return value of prev_calculated for next call
   return(rates_total);
  }
//+------------------------------------------------------------------+



double Cov(string X , string Y){
      
      
      
      // Return = Curr/prev -1
      
      
      double muX = 0;
      double muY = 0;
      double DetrendX[];
      double DetrendY[];
      ArrayResize(DetrendX,InpDepthOfMarket);
      ArrayResize(DetrendY,InpDepthOfMarket);   
      for(int i = InpDepthOfMarket-1 ; i>=0;i--){
         
         muX += iClose(MarketX,TF,i)/iClose(MarketX,TF,i+1) -1 ;
         muY += iClose(MarketY,TF,i)/iClose(MarketY,TF,i+1) -1 ;
         DetrendX[InpDepthOfMarket-1 -i] = iClose(MarketX,TF,i)/iClose(MarketX,TF,i+1) -1 ;
         DetrendY[InpDepthOfMarket-1 -i] = iClose(MarketY,TF,i)/iClose(MarketY,TF,i+1) -1 ;
      }
      
      muX = muX/InpDepthOfMarket;
      muY = muY/InpDepthOfMarket;
      double cov = 0 ;
      
      for(int i = 0 ; i <InpDepthOfMarket;i++){
      
         cov += (DetrendX[i]-muX)*(DetrendY[i]-muY);
      
      }
      
      
      ArrayFree(DetrendX);
      ArrayFree(DetrendY);
      return cov/(InpDepthOfMarket-1);


}

double Var(string Y){


      double muY = 0;
      
      double DetrendY[];
      
      ArrayResize(DetrendY,InpDepthOfMarket);   
      for(int i = InpDepthOfMarket-1 ; i>=0;i--){
         
         
         muY += iClose(MarketY,TF,i)/iClose(MarketY,TF,i+1) -1 ;
         
         DetrendY[InpDepthOfMarket-1 -i] = iClose(MarketY,TF,i)/iClose(MarketY,TF,i+1) -1 ;
      }
      muY = muY/InpDepthOfMarket;
      double var = 0 ;
      
      for(int i = 0 ; i <InpDepthOfMarket;i++){
      
         var += pow(DetrendY[i]-muY,2);
      
      }
      ArrayFree(DetrendY);
      return var/(InpDepthOfMarket-1);





}