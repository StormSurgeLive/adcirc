#include <stdio.h>
#include <string.h>
#include "grb2.h"
#include "wgrib2.h"
#include "fnlist.h"

/*
 * 2/2007 Public Domain: Wesley Ebisuzaki
 * 1/2016 Wesley Ebisuzaki: for PDT=2 and 12 (derived fcst based on ALL ensemble members)
 *               changed the descriptions to remove mention of clusters
 * 2/2022: Manfred Schwarb: ECMWF enemble forecasts have missing typeOfEnsembleForecast
 *              code table 4.7 to 0 (ctl) or 3 (ens member)
 */

/*
 * HEADER:200:ens:inv:0:ensemble information
 */

int f_ens(ARG0) {
    int n, pert, typefcst, pdt, center;
    static int ecmwf_warning_count = 0;
    const char *string;
    unsigned char *type;

    if (mode >= 0) {
	typefcst = code_table_4_7(sec);
	type = code_table_4_6_location(sec);
	center = GB2_Center(sec);
        pdt =  GB2_ProdDefTemplateNo(sec);
	n = number_of_forecasts_in_the_ensemble(sec);
	pert = perturbation_number(sec);

       /*
        * ECMWF hack: type missing although numberOfForecastsInEnsemble > 0
        * and perturbationNumber >= 0
	* ECMWF only have low-res controls and positive ensemble members
        */
        if (center == ECMWF && type && *type == 255 && n > 0 && pert >= 0) {
	    *type = pert == 0 ? 1 : 3;
	    if (ecmwf_warning_count++ < 4) fprintf(stderr,"WARNING: Code Table 4.6 is undefined, set to %d\n", *type);
        }

	if (type != NULL) {
	    switch(*type) {
	        case 0: sprintf(inv_out,"ENS=hi-res ctl"); break;
	        case 1: sprintf(inv_out,"ENS=low-res ctl"); break;
	        case 2: 
			sprintf(inv_out,"ENS=-%d", pert); break;
	        case 3: 
			sprintf(inv_out,"ENS=+%d", pert); break;
	        case 4: 
			sprintf(inv_out,"MM-ENS=%d", pert); break;
		case 192:
			if (center == NCEP) {
			    sprintf(inv_out,"ENS=%d", pert); break;
			}
                        /* fall through */
	        default:
			sprintf(inv_out,"ENS=? table4.6=%d pert=%d",(int) *type,pert); break;
	    }
	    inv_out += strlen(inv_out);
	    if (typefcst >= 0) {
		*inv_out++=' ';
		*inv_out=0;
	    }
	}
	if (typefcst >= 0) {	/* is a derived forecast  with code table 4.7 */
	    string = "unknown derived fcst";
	    switch(typefcst) {
	        case 0: string = "ens mean"; break;
	        case 1: string = "wt ens mean"; break;
	        case 2: if ((pdt == 2) || (pdt == 12)) {
			    string = "ens std dev"; break;
			}
			string = "cluster std dev"; break;
	        case 3: if ((pdt == 2) || (pdt == 12)) {
			    string = "normalized ens std dev"; break;
			}
			string = "normalized cluster std dev"; break;
	        case 4: string = "ens spread"; break;
	        case 5: string = "ens large anom index"; break;
	        case 6: if ((pdt == 2) || (pdt == 12)) {
			    string = "unwt ens mean"; break;
			}
			string = "unwt cluster mean"; break;
	        case 7: string = "25%-75% range"; break;
	        case 8: string = "min all members"; break;
	        case 9: string = "max all members"; break;
	        case 192: if (center == NCEP)  string = "unwt mode all members"; break;
	        case 193: if (center == NCEP)  string = "10% all members"; break;
	        case 194: if (center == NCEP)  string = "50% all members"; break;
	        case 195: if (center == NCEP)  string = "90% all members"; break;
	        case 196: if (center == NCEP)  string = "stat. weight for each members"; break;
	        case 197: if (center == NCEP)  string = "percentile from climate distribution"; break;
	        case 198: if (center == NCEP)  string = "deviation of ens mean from daily climo"; break;
	        case 199: if (center == NCEP)  string = "extreme forecast index"; break;
	        case 200: if (center == NCEP)  string = "equally weighted mean"; break;
	        case 201: if (center == NCEP)  string = "5% all members"; break;
	        case 202: if (center == NCEP)  string = "25% all members"; break;
	        case 203: if (center == NCEP)  string = "75% all members"; break;
	        case 204: if (center == NCEP)  string = "95% all members"; break;
	    }
	    sprintf(inv_out,"%s", string);
	    inv_out += strlen(inv_out);
	}
    }
    return 0;
}

/*
 * HEADER:200:N_ens:inv:0:number of ensemble members
 */
int f_N_ens(ARG0) {
    int n;
    unsigned char *p;

    if (mode >= 0) {
	p = number_of_forecasts_in_the_ensemble_location(sec);
	if (p) {
	    n = *p;
	    if (n == 255) n = -1;
	    sprintf(inv_out,"%d ens members", n); 
	}
    }
    return 0;
}
