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

#import "THShaderProgram.h"
#import <GLKit/GLKit.h>

// Attribute index.
enum {
    ATTRIB_VERTEX,
    ATTRIB_TEXCOORDS,
    NUM_ATTRIBUTES
};

@interface THShaderProgram ()
@property (nonatomic) GLuint shaderProgram;
@property (nonatomic) GLuint vertShader;
@property (nonatomic) GLuint fragShader;
@property (strong, nonatomic) NSMutableArray *attributes;
@property (strong, nonatomic) NSMutableArray *uniforms;
@end

@implementation THShaderProgram

- (instancetype)initWithShaderName:(NSString *)name {
    self = [super init];
    if (self) {

        // Create shader program.
        _shaderProgram = glCreateProgram();

        NSString *vertShaderPath = [self pathForName:name type:@"vsh"];
        if (![self compileShader:&_vertShader type:GL_VERTEX_SHADER file:vertShaderPath]) {
            NSLog(@"Failed to compile vertex shader");
            self = nil;
            return self;
        }

        NSString *fragShaderPath = [self pathForName:name type:@"fsh"];
        if (![self compileShader:&_fragShader type:GL_FRAGMENT_SHADER file:fragShaderPath]) {
            NSLog(@"Failed to compile fragment shader");
            self = nil;
            return self;
        }

        // Attach vertex shader to program.
        glAttachShader(_shaderProgram, _vertShader);

        // Attach fragment shader to program.
        glAttachShader(_shaderProgram, _fragShader);
    }
    return self;
}

- (NSString *)pathForName:(NSString *)name type:(NSString *)type {
    return [[NSBundle mainBundle] pathForResource:name ofType:type];
}

- (void)addVertextAttribute:(GLKVertexAttrib)attribute named:(NSString *)name {
    glBindAttribLocation(_shaderProgram, attribute, [name UTF8String]);
}

- (GLuint)uniformIndex:(NSString *)uniform {
    return glGetUniformLocation(_shaderProgram, [uniform UTF8String]);
}

- (BOOL)compileShader:(GLuint *)shader type:(GLenum)type file:(NSString *)file {
    GLint status;
    const GLchar *source;

    source = (GLchar *)[[NSString stringWithContentsOfFile:file encoding:NSUTF8StringEncoding error:nil] UTF8String];
    if (!source) {
        NSLog(@"Failed to load vertex shader");
        return NO;
    }

    *shader = glCreateShader(type);
    glShaderSource(*shader, 1, &source, NULL);
    glCompileShader(*shader);

#if defined(DEBUG)
    GLint logLength;
    glGetShaderiv(*shader, GL_INFO_LOG_LENGTH, &logLength);
    if (logLength > 0) {
        GLchar *log = (GLchar *)malloc(logLength);
        glGetShaderInfoLog(*shader, logLength, &logLength, log);
        NSLog(@"Shader compile log:\n%s", log);
        free(log);
    }
#endif

    glGetShaderiv(*shader, GL_COMPILE_STATUS, &status);
    if (status == 0) {
        glDeleteShader(*shader);
        return NO;
    }

    return YES;
}

- (BOOL)linkProgram {
    GLint status;
    glLinkProgram(_shaderProgram);

    glGetProgramiv(_shaderProgram, GL_LINK_STATUS, &status);
    if (status == 0) {
        return NO;
    }

    // Release vertex and fragment shaders.
    if (_vertShader) {
        glDetachShader(_shaderProgram, _vertShader);
        glDeleteShader(_vertShader);
    }

    if (_fragShader) {
        glDetachShader(_shaderProgram, _fragShader);
        glDeleteShader(_fragShader);
    }

    return YES;
}

- (void)useProgram {
    glUseProgram(_shaderProgram);
}

@end
