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

static struct {
        NSString *str, *repl;
} smileys[]= {
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

        {   @"O_o",  @""    },      // surprised: e40d -- big oh, little oh
        {   @"0_o", @""    },      // surprised: e40d -- zero, little oh
        {   @"o_O",  @""    },      // surprised: e40d -- little oh, big oh
        {   @"o_0", @""    },      // surprised: e40d -- little oh, zero

        {   @"<3",  @""    },      // heart: e022
};

static NSDictionary *smileys_dict = NULL;

@implementation NSString(emojisxx)
+(void)reloadSmileys {
	NSString *path = [NSBundle pathForResource:@"smileys"
										ofType:@"strings" 
								   inDirectory:@"/Library/Application Support/ID.bundle"];
    
	NSDictionary *dict = [[NSDictionary dictionaryWithContentsOfFile:path] retain];

    [smileys_dict release];
    smileys_dict = [[NSMutableDictionary dictionary] retain];

    for (unsigned i = 0; i < sizeof(smileys)/sizeof(smileys[0]); i++) {
        [smileys_dict setValue:smileys[i].repl forKey:smileys[i].str];
    }
    if (dict != nil) {
        for (NSString *k in [dict keyEnumerator]) {
            [smileys_dict setValue:[dict valueForKey:k] forKey:k];
        }
    }
}

-(BOOL)containsEmojixx {
    for (NSString *k in [smileys_dict keyEnumerator]) {
        NSRange r = [self rangeOfString:[smileys_dict valueForKey:k]];
        if (r.location != NSNotFound) {
            return YES;
        }
    }
    return NO;
}

-(NSString *)replaceSmileys {
    NSString *str = self;
    for (NSString *k in [smileys_dict keyEnumerator]) {
            str = [str stringByReplacingOccurrencesOfString:k
                                                 withString:[smileys_dict valueForKey:k]
                                                    options:NSCaseInsensitiveSearch   
                                                      range:NSMakeRange(0, [str length])];
    }

    return str;
}
@end
// vim: ft=objc ts=4 expandtab
