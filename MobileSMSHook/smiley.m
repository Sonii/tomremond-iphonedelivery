/*
 Copyright (C) 2011 - F. Guillemé
 This program is free software; you can redistribute it and/or
 modify it under the terms of the GNU General Public License
 as published by the Free Software Foundation; either version 2
 of the License, or (at your option) any later version.

 This program is distributed in the hope that it will be useful,
 but WITHOUT ANY WARRANTY; without even the implied warranty of
 MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 GNU General Public License for more details.

 You should have received a copy of the GNU General Public License
 along with this program; if not, write to the Free Software
 Foundation, Inc., 59 Temple Place - Suite 330, Boston, MA  02111-1307, USA.
*/

NSString *replaceSmileys(NSString *s) {
    struct {
        NSString *str, *repl;
    }
    smileys[]= {
        {   @":-)",  @"",  },      // smile: 0xe414
        {   @":)",  @"",   },      // smile: 0xe414

        {   @"^^",  @"",   },      // smile: 0xe056
        
        {   @":-(", @""    },      // sad: e058
        {   @":(",  @""    },      // sad: e058
        
        {   @":-D", @""    },      // laugh: e057
        {   @":D",  @""    },      // laugh: e057
        {   @"lol", @""    },      // laugh: e415

        {   @"(L)", @""    },      // e106
        {   @"(K)", @""    },      // e418
        {   @"(H)", @""    },      // e402
        
        {   @":-P", @""    },      // tongue: e105
        {   @":P",  @""    },      // tongue: e105

        {   @";-)", @""    },      // wink: e405
        {   @";)",  @""    },      // wink: e405
        
        {   @":o",  @""    },      // surprised: e40d
        {   @":-o", @""    },      // surprised: e40d
        
        {   @":|",  @""    },      // e404
        {   @" :/", @""    },      // e108
        {   @":-/", @""    },      // e108
        {   @":x",  @""    },      // e407

        {   @">_<", @""    },      // e409
        {   @"-_-", @""    },      // e40e

        {   @":@",  @""    },      // angry: e416
        {   @":-@", @""    },      // angry: e416

        {   @":-S", @""    },      // crossed: e407
        {   @":S",  @""    },      // crossed: e407

        {   @":$",  @""    },      // dumb : e417
        {   @":-$", @""    },      // dumb : e417 

        {   @"B-)", @""    },      // star: e106 but not correct

        {   @":'(", @""    },      // crying: e401

        {   @":-*", @""    },      // kiss: e418
        {   @":*",  @""    },      // kiss: e418
    };

    for (unsigned i = 0; i < sizeof(smileys)/sizeof(smileys[0]); i++) {
            s = [s stringByReplacingOccurrencesOfString:smileys[i].str 
                                              withString:smileys[i].repl
                                                options:NSCaseInsensitiveSearch   
                                                range:NSMakeRange(0, [s length])];
    }

    return s;
}
// vim: ft=objc ts=4 expandtab
