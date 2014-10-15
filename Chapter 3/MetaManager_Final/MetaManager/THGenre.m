//
//  MIT License
//
//  Copyright (c) 2014 Bob McCune http://bobmccune.com/
//  Copyright (c) 2014 TapHarmonic, LLC http://tapharmonic.com/
//
//  Permission is hereby granted, free of charge, to any person obtaining a copy
//  of this software and associated documentation files (the "Software"), to deal
//  in the Software without restriction, including without limitation the rights
//  to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
//  copies of the Software, and to permit persons to whom the Software is
//  furnished to do so, subject to the following conditions:
//
//  The above copyright notice and this permission notice shall be included in
//  all copies or substantial portions of the Software.
//
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
//  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
//  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
//  OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
//  THE SOFTWARE.
//

#import "THGenre.h"

@implementation THGenre

+ (NSArray *)videoGenres {
    static dispatch_once_t predicate;
    static NSArray *videoGenres = nil;
    dispatch_once(&predicate, ^{
        videoGenres = @[[[THGenre alloc] initWithIndex:4000 name:@"Comedy"],
            [[THGenre alloc] initWithIndex:4001 name:@"Drama"],
            [[THGenre alloc] initWithIndex:4002 name:@"Animation"],
            [[THGenre alloc] initWithIndex:4003 name:@"Action & Adventure"],
            [[THGenre alloc] initWithIndex:4004 name:@"Classic"],
            [[THGenre alloc] initWithIndex:4005 name:@"Kids"],
            [[THGenre alloc] initWithIndex:4006 name:@"Nonfiction"],
            [[THGenre alloc] initWithIndex:4007 name:@"Reality TV"],
            [[THGenre alloc] initWithIndex:4008 name:@"Sci-Fi & Fantasy"],
            [[THGenre alloc] initWithIndex:4009 name:@"Sports"],
            [[THGenre alloc] initWithIndex:4010 name:@"Teens"],
            [[THGenre alloc] initWithIndex:4011 name:@"Latino TV"]];
    });
    return videoGenres;
}

+ (NSArray *)musicGenres {
    static dispatch_once_t predicate;
    static NSArray *musicGenres = nil;
    dispatch_once(&predicate, ^{
        musicGenres = @[[[THGenre alloc] initWithIndex:0 name:@"Blues"],
            [[THGenre alloc] initWithIndex:1 name:@"Classic Rock"],
            [[THGenre alloc] initWithIndex:2 name:@"Country"],
            [[THGenre alloc] initWithIndex:3 name:@"Dance"],
            [[THGenre alloc] initWithIndex:4 name:@"Disco"],
            [[THGenre alloc] initWithIndex:5 name:@"Funk"],
            [[THGenre alloc] initWithIndex:6 name:@"Grunge"],
            [[THGenre alloc] initWithIndex:7 name:@"Hip-Hop"],
            [[THGenre alloc] initWithIndex:8 name:@"Jazz"],
            [[THGenre alloc] initWithIndex:9 name:@"Metal"],
            [[THGenre alloc] initWithIndex:10 name:@"New Age"],
            [[THGenre alloc] initWithIndex:11 name:@"Oldies"],
            [[THGenre alloc] initWithIndex:12 name:@"Other"],
            [[THGenre alloc] initWithIndex:13 name:@"Pop"],
            [[THGenre alloc] initWithIndex:14 name:@"R&B"],
            [[THGenre alloc] initWithIndex:15 name:@"Rap"],
            [[THGenre alloc] initWithIndex:16 name:@"Reggae"],
            [[THGenre alloc] initWithIndex:17 name:@"Rock"],
            [[THGenre alloc] initWithIndex:18 name:@"Techno"],
            [[THGenre alloc] initWithIndex:19 name:@"Industrial"],
            [[THGenre alloc] initWithIndex:20 name:@"Alternative"],
            [[THGenre alloc] initWithIndex:21 name:@"Ska"],
            [[THGenre alloc] initWithIndex:22 name:@"Death Metal"],
            [[THGenre alloc] initWithIndex:23 name:@"Pranks"],
            [[THGenre alloc] initWithIndex:24 name:@"Soundtrack"],
            [[THGenre alloc] initWithIndex:25 name:@"Euro-Techno"],
            [[THGenre alloc] initWithIndex:26 name:@"Ambient"],
            [[THGenre alloc] initWithIndex:27 name:@"Trip-Hop"],
            [[THGenre alloc] initWithIndex:28 name:@"Vocal"],
            [[THGenre alloc] initWithIndex:29 name:@"Jazz+Funk"],
            [[THGenre alloc] initWithIndex:30 name:@"Fusion"],
            [[THGenre alloc] initWithIndex:31 name:@"Trance"],
            [[THGenre alloc] initWithIndex:32 name:@"Classical"],
            [[THGenre alloc] initWithIndex:33 name:@"Instrumental"],
            [[THGenre alloc] initWithIndex:34 name:@"Acid"],
            [[THGenre alloc] initWithIndex:35 name:@"House"],
            [[THGenre alloc] initWithIndex:36 name:@"Game"],
            [[THGenre alloc] initWithIndex:37 name:@"Sound Clip"],
            [[THGenre alloc] initWithIndex:38 name:@"Gospel"],
            [[THGenre alloc] initWithIndex:39 name:@"Noise"],
            [[THGenre alloc] initWithIndex:40 name:@"AlternRock"],
            [[THGenre alloc] initWithIndex:41 name:@"Bass"],
            [[THGenre alloc] initWithIndex:42 name:@"Soul"],
            [[THGenre alloc] initWithIndex:43 name:@"Punk"],
            [[THGenre alloc] initWithIndex:44 name:@"Space"],
            [[THGenre alloc] initWithIndex:45 name:@"Meditative"],
            [[THGenre alloc] initWithIndex:46 name:@"Instrumental Pop"],
            [[THGenre alloc] initWithIndex:47 name:@"Instrumental Rock"],
            [[THGenre alloc] initWithIndex:48 name:@"Ethnic"],
            [[THGenre alloc] initWithIndex:49 name:@"Gothic"],
            [[THGenre alloc] initWithIndex:50 name:@"Darkwave"],
            [[THGenre alloc] initWithIndex:51 name:@"Techno-Industrial"],
            [[THGenre alloc] initWithIndex:52 name:@"Electronic"],
            [[THGenre alloc] initWithIndex:53 name:@"Pop-Folk"],
            [[THGenre alloc] initWithIndex:54 name:@"Eurodance"],
            [[THGenre alloc] initWithIndex:55 name:@"Dream"],
            [[THGenre alloc] initWithIndex:56 name:@"Southern Rock"],
            [[THGenre alloc] initWithIndex:57 name:@"Comedy"],
            [[THGenre alloc] initWithIndex:58 name:@"Cult"],
            [[THGenre alloc] initWithIndex:59 name:@"Gangsta"],
            [[THGenre alloc] initWithIndex:60 name:@"Top 40"],
            [[THGenre alloc] initWithIndex:61 name:@"Christian Rap"],
            [[THGenre alloc] initWithIndex:62 name:@"Pop/Funk"],
            [[THGenre alloc] initWithIndex:63 name:@"Jungle"],
            [[THGenre alloc] initWithIndex:64 name:@"Native American"],
            [[THGenre alloc] initWithIndex:65 name:@"Cabaret"],
            [[THGenre alloc] initWithIndex:66 name:@"New Wave"],
            [[THGenre alloc] initWithIndex:67 name:@"Psychedelic"],
            [[THGenre alloc] initWithIndex:68 name:@"Rave"],
            [[THGenre alloc] initWithIndex:69 name:@"Showtunes"],
            [[THGenre alloc] initWithIndex:70 name:@"Trailer"],
            [[THGenre alloc] initWithIndex:71 name:@"Lo-Fi"],
            [[THGenre alloc] initWithIndex:72 name:@"Tribal"],
            [[THGenre alloc] initWithIndex:73 name:@"Acid Punk"],
            [[THGenre alloc] initWithIndex:74 name:@"Acid Jazz"],
            [[THGenre alloc] initWithIndex:75 name:@"Polka"],
            [[THGenre alloc] initWithIndex:76 name:@"Retro"],
            [[THGenre alloc] initWithIndex:77 name:@"Musical"],
            [[THGenre alloc] initWithIndex:78 name:@"Rock & Roll"],
            [[THGenre alloc] initWithIndex:79 name:@"Hard Rock"],
            [[THGenre alloc] initWithIndex:80 name:@"Folk"],
            [[THGenre alloc] initWithIndex:81 name:@"Folk-Rock"],
            [[THGenre alloc] initWithIndex:82 name:@"National Folk"],
            [[THGenre alloc] initWithIndex:83 name:@"Swing"],
            [[THGenre alloc] initWithIndex:84 name:@"Fast Fusion"],
            [[THGenre alloc] initWithIndex:85 name:@"Bebob"],
            [[THGenre alloc] initWithIndex:86 name:@"Latin"],
            [[THGenre alloc] initWithIndex:87 name:@"Revival"],
            [[THGenre alloc] initWithIndex:88 name:@"Celtic"],
            [[THGenre alloc] initWithIndex:89 name:@"Bluegrass"],
            [[THGenre alloc] initWithIndex:90 name:@"Avantgarde"],
            [[THGenre alloc] initWithIndex:91 name:@"Gothic Rock"],
            [[THGenre alloc] initWithIndex:92 name:@"Progressive Rock"],
            [[THGenre alloc] initWithIndex:93 name:@"Psychedelic Rock"],
            [[THGenre alloc] initWithIndex:94 name:@"Symphonic Rock"],
            [[THGenre alloc] initWithIndex:95 name:@"Slow Rock"],
            [[THGenre alloc] initWithIndex:96 name:@"Big Band"],
            [[THGenre alloc] initWithIndex:97 name:@"Chorus"],
            [[THGenre alloc] initWithIndex:98 name:@"Easy Listening"],
            [[THGenre alloc] initWithIndex:99 name:@"Acoustic"],
            [[THGenre alloc] initWithIndex:100 name:@"Humour"],
            [[THGenre alloc] initWithIndex:101 name:@"Speech"],
            [[THGenre alloc] initWithIndex:102 name:@"Chanson"],
            [[THGenre alloc] initWithIndex:103 name:@"Opera"],
            [[THGenre alloc] initWithIndex:104 name:@"Chamber Music"],
            [[THGenre alloc] initWithIndex:105 name:@"Sonata"],
            [[THGenre alloc] initWithIndex:106 name:@"Symphony"],
            [[THGenre alloc] initWithIndex:107 name:@"Booty Bass"],
            [[THGenre alloc] initWithIndex:108 name:@"Primus"],
            [[THGenre alloc] initWithIndex:109 name:@"Porn Groove"],
            [[THGenre alloc] initWithIndex:110 name:@"Satire"],
            [[THGenre alloc] initWithIndex:111 name:@"Slow Jam"],
            [[THGenre alloc] initWithIndex:112 name:@"Club"],
            [[THGenre alloc] initWithIndex:113 name:@"Tango"],
            [[THGenre alloc] initWithIndex:114 name:@"Samba"],
            [[THGenre alloc] initWithIndex:115 name:@"Folklore"],
            [[THGenre alloc] initWithIndex:116 name:@"Ballad"],
            [[THGenre alloc] initWithIndex:117 name:@"Power Ballad"],
            [[THGenre alloc] initWithIndex:118 name:@"Rhythmic Soul"],
            [[THGenre alloc] initWithIndex:119 name:@"Freestyle"],
            [[THGenre alloc] initWithIndex:120 name:@"Duet"],
            [[THGenre alloc] initWithIndex:121 name:@"Punk Rock"],
            [[THGenre alloc] initWithIndex:122 name:@"Drum Solo"],
            [[THGenre alloc] initWithIndex:123 name:@"A Capella"],
            [[THGenre alloc] initWithIndex:124 name:@"Euro-House"],
            [[THGenre alloc] initWithIndex:125 name:@"Dance Hall"]];
    });
    return musicGenres;
}

+ (THGenre *)id3GenreWithName:(NSString *)name {
    for (THGenre *genre in [self musicGenres]) {
        if ([genre.name isEqualToString:name]) {
            return genre;
        }
    }
    return [[THGenre alloc] initWithIndex:255 name:name];
}

+ (THGenre *)id3GenreWithIndex:(NSUInteger)genreIndex {
    for (THGenre *genre in [self musicGenres]) {
        if (genre.index == genreIndex) {
            return genre;
        }
    }
    return [[THGenre alloc] initWithIndex:255 name:@"Custom"];
}

+ (THGenre *)iTunesGenreWithIndex:(NSUInteger)genreIndex {
    return [self id3GenreWithIndex:genreIndex - 1];
}

+ (THGenre *)videoGenreWithName:(NSString *)name {
    for (THGenre *genre in [self videoGenres]) {
        if ([genre.name isEqualToString:name]) {
            return genre;
        }
    }
    return nil;
}

- (instancetype)initWithIndex:(NSUInteger)genreIndex name:(NSString *)name {
    self = [super init];
    if (self) {
        _index = genreIndex;
        _name = [name copy];
    }
    return self;
}

- (id)copyWithZone:(NSZone *)zone {
    return [[THGenre alloc] initWithIndex:_index name:_name];
}

- (NSString *)description {
    return self.name;
}

- (BOOL)isEqual:(id)other {
    if (self == other) {
        return YES;
    }
    if (!other || ![other isMemberOfClass:[self class]]) {
        return NO;
    }
    return self.index == [other index] && [self.name isEqual:[other name]];
}

- (NSUInteger)hash {
    NSUInteger prime = 37;
    NSUInteger hash = 0;
    hash += (_index + 1) * prime;
    hash += [self.name hash] * prime;
    return hash;
}

@end
