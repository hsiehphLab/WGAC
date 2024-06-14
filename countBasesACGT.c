#include    <stdio.h>
#include    <ctype.h>
#include    <stdbool.h>
#include <locale.h>


int main( int argc, char* argv[] ) {
   char szLastHeader[10000];
   long long llHeaderLength = 0;
   long long llNumberOfBases = 0;
   bool bInHeader = false;
   long long llNumberOfBasesAllSequences = 0;
   char c = 'x';
   long long llAs = 0;
   long long llCs = 0;
   long long llGs = 0;
   long long llTs = 0;
   long long llNs = 0;
   long long llOthers = 0;
   long long llNOrLowercase = 0;
   long long llNumberOfLowercaseBasesAllSequences = 0;
   long long llCsJustOneSequence = 0;
   long long llGsJustOneSequence = 0;
   long long llNsJustOneSequence = 0;
   long long llLowercaseJustOneSequence = 0;


   if ( argc > 1 ) {
      fprintf( stderr, "Fatal error: reads from stdin\n" );
      return( 1 );
   }


   // needed for printing commas in a number
#define _POSIX_C_SOURCE 200809L   
   setlocale(LC_NUMERIC, "");
   setlocale(LC_ALL, "");

   bool bFirstTime = true;
   while( 1 ) {
      c = getchar();
      if ( c == EOF  || c == '>' ) {
         if ( bFirstTime ) {
            bFirstTime = false;
         }
         else {
            szLastHeader[ llHeaderLength ] = 0;
            printf( "%s has %lld or %'lld bases lowercase %.1f%% N's %lld\n",  
                    szLastHeader, llNumberOfBases, llNumberOfBases, llLowercaseJustOneSequence * 100.0 / llNumberOfBases, llNsJustOneSequence );
            llNumberOfBasesAllSequences += llNumberOfBases;
            llNumberOfLowercaseBasesAllSequences += llLowercaseJustOneSequence;


            llCsJustOneSequence = 0;
            llGsJustOneSequence = 0;
            llNsJustOneSequence = 0;
            llLowercaseJustOneSequence = 0;

            if ( c == EOF ) break;
         }
         bInHeader = true;
         szLastHeader[0] = 0;
         llHeaderLength = 0;
         llNumberOfBases = 0;
      }
      else {
         if ( bInHeader ) {
            if ( c == '\n' ) {
               bInHeader = false;
            }
            else {
               szLastHeader[ llHeaderLength ] = c;
               ++llHeaderLength;
            }
         }
         else {
            if ( !isspace( c )  ) {
               ++llNumberOfBases;
               if ( islower(c) ) {
                  ++llLowercaseJustOneSequence;
               }
               char cUpper = toupper( c );
               if ( cUpper == 'A' ) {
                  ++llAs;
               }
               else if ( cUpper == 'C' ) {
                  ++llCs;
                  ++llCsJustOneSequence;
               }
               else if ( cUpper == 'G' ) {
                  ++llGs;
                  ++llGsJustOneSequence;
               }
               else if ( cUpper == 'T' ) {
                  ++llTs;
               }
               else if ( cUpper == 'N' ) {
                  ++llNs;
                  ++llNsJustOneSequence;
               }
               else {
                  ++llOthers;
               }

               if ( islower(c) || ( c == 'N' ) ) {
                  ++llNOrLowercase;
               }
            }
         }
      }
   }

   printf( "number of bases all sequences: %lld %'lld\n", 
        llNumberOfBasesAllSequences, 
        llNumberOfBasesAllSequences );
   printf( "lowercase bases all sequences: %lld %'lld ( %.2f %% )\n",
           llNumberOfLowercaseBasesAllSequences,
           llNumberOfLowercaseBasesAllSequences,
           llNumberOfLowercaseBasesAllSequences * 100.0 / llNumberOfBasesAllSequences );

   printf( "A: %'lld C: %'lld G: %'lld T: %'lld N: %'lld (%.1f %%) Other: %'lld\n", llAs, llCs, llGs, llTs, llNs, llNs * 100.0 / llNumberOfBasesAllSequences , llOthers );

   printf( "GC content: %.1f%%\n", ( llCs + llGs ) * 100.0 / llNumberOfBasesAllSequences );

   printf( "N or lowercase: %lld %'lld\n",  llNOrLowercase,  llNOrLowercase );

   return 0;
}


