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

#define BUFFER_OFFSET(i) ((char *)NULL + (i))

#import "THViewController.h"
#import <GLKit/GLKit.h>
#import "THCameraController.h"
#import "THShaderProgram.h"
#import <OpenGLES/ES2/gl.h>
#import <OpenGLES/ES2/glext.h>

// Uniform index.
enum {
    UNIFORM_MVP_MATRIX,
    UNIFORM_TEXTURE,
    NUM_UNIFORMS
};
GLint uniforms[NUM_UNIFORMS];

@interface THViewController () <THTextureDelegate>
@property (strong, nonatomic) EAGLContext *context;
@property (strong, nonatomic) THCameraController *cameraController;
@property (strong, nonatomic) THShaderProgram *shaderProgram;
@end

@implementation THViewController {
    GLKMatrix4 _mvpMatrix;
    float _rotation;

    GLuint _vertexArray;
    GLuint _vertexBuffer;
}

- (void)viewDidLoad {
	[super viewDidLoad];
	self.context = [[EAGLContext alloc] initWithAPI:kEAGLRenderingAPIOpenGLES2];

    if (!self.context) {
        NSLog(@"Failed to create OpenGL ES 2.0 context");
    }

    GLKView *view = (GLKView *)self.view;
    view.context = self.context;
    view.drawableDepthFormat = GLKViewDrawableDepthFormat24;

    [self setUpGL];

    NSError *error;
    self.cameraController = [[THCameraController alloc] initWithContext:self.context];
    self.cameraController.textureDelegate = self;
    if ([self.cameraController setupSession:&error]) {
        [self.cameraController switchCameras];
        [self.cameraController startSession];
    } else {
        NSLog(@"Error: %@", [error localizedDescription]);
    }
}

- (void)setUpGL {
	GLfloat cubeVertices[] = {
    //  Position                 Normal                  Texture
     // x,    y,     z           x,    y,    z           s,    t
        0.5f, -0.5f, -0.5f,      1.0f, 0.0f, 0.0f,       1.0f, 1.0f,
        0.5f,  0.5f, -0.5f,      1.0f, 0.0f, 0.0f,       1.0f, 0.0f,
        0.5f, -0.5f,  0.5f,      1.0f, 0.0f, 0.0f,       0.0f, 1.0f,
        0.5f, -0.5f,  0.5f,      1.0f, 0.0f, 0.0f,       0.0f, 1.0f,
        0.5f,  0.5f, -0.5f,      1.0f, 0.0f, 0.0f,       1.0f, 0.0f,
        0.5f,  0.5f,  0.5f,      1.0f, 0.0f, 0.0f,       0.0f, 0.0f,

        0.5f, 0.5f, -0.5f,       0.0f, 1.0f, 0.0f,       1.0f, 0.0f,
       -0.5f, 0.5f, -0.5f,       0.0f, 1.0f, 0.0f,       0.0f, 0.0f,
        0.5f, 0.5f,  0.5f,       0.0f, 1.0f, 0.0f,       1.0f, 1.0f,
        0.5f, 0.5f,  0.5f,       0.0f, 1.0f, 0.0f,       1.0f, 1.0f,
       -0.5f, 0.5f, -0.5f,       0.0f, 1.0f, 0.0f,       0.0f, 0.0f,
       -0.5f, 0.5f,  0.5f,       0.0f, 1.0f, 0.0f,       0.0f, 1.0f,

       -0.5f,  0.5f, -0.5f,     -1.0f, 0.0f, 0.0f,       0.0f, 1.0f,
       -0.5f, -0.5f, -0.5f,     -1.0f, 0.0f, 0.0f,       1.0f, 1.0f,
       -0.5f,  0.5f,  0.5f,     -1.0f, 0.0f, 0.0f,       0.0f, 0.0f,
       -0.5f,  0.5f,  0.5f,     -1.0f, 0.0f, 0.0f,       0.0f, 0.0f,
       -0.5f, -0.5f, -0.5f,     -1.0f, 0.0f, 0.0f,       1.0f, 1.0f,
       -0.5f, -0.5f,  0.5f,     -1.0f, 0.0f, 0.0f,       1.0f, 0.0f,

       -0.5f, -0.5f, -0.5f,      0.0f, -1.0f, 0.0f,      1.0f, 0.0f,
        0.5f, -0.5f, -0.5f,      0.0f, -1.0f, 0.0f,      0.0f, 0.0f,
       -0.5f, -0.5f,  0.5f,      0.0f, -1.0f, 0.0f,      1.0f, 1.0f,
       -0.5f, -0.5f,  0.5f,      0.0f, -1.0f, 0.0f,      1.0f, 1.0f,
        0.5f, -0.5f, -0.5f,      0.0f, -1.0f, 0.0f,      0.0f, 0.0f,
        0.5f, -0.5f,  0.5f,      0.0f, -1.0f, 0.0f,      0.0f, 1.0f,

        0.5f,  0.5f, 0.5f,       0.0f, 0.0f, 1.0f,       0.0f, 0.0f,
       -0.5f,  0.5f, 0.5f,       0.0f, 0.0f, 1.0f,       0.0f, 1.0f,
        0.5f, -0.5f, 0.5f,       0.0f, 0.0f, 1.0f,       1.0f, 0.0f,
        0.5f, -0.5f, 0.5f,       0.0f, 0.0f, 1.0f,       1.0f, 0.0f,
       -0.5f,  0.5f, 0.5f,       0.0f, 0.0f, 1.0f,       0.0f, 1.0f,
       -0.5f, -0.5f, 0.5f,       0.0f, 0.0f, 1.0f,       1.0f, 1.0f,

        0.5f, -0.5f, -0.5f,      0.0f, 0.0f, -1.0f,      0.0f, 1.0f,
       -0.5f, -0.5f, -0.5f,      0.0f, 0.0f, -1.0f,      1.0f, 1.0f,
        0.5f,  0.5f, -0.5f,      0.0f, 0.0f, -1.0f,      0.0f, 0.0f,
        0.5f,  0.5f, -0.5f,      0.0f, 0.0f, -1.0f,      0.0f, 0.0f,
       -0.5f, -0.5f, -0.5f,      0.0f, 0.0f, -1.0f,      1.0f, 1.0f,
       -0.5f,  0.5f, -0.5f,      0.0f, 0.0f, -1.0f,      1.0f, 0.0f
	};

	[EAGLContext setCurrentContext:self.context];

    self.shaderProgram = [[THShaderProgram alloc] initWithShaderName:@"Shader"];
    [self.shaderProgram addVertextAttribute:GLKVertexAttribPosition named:@"position"];
    [self.shaderProgram addVertextAttribute:GLKVertexAttribTexCoord0 named:@"videoTextureCoordinate"];
    [self.shaderProgram linkProgram];

    uniforms[UNIFORM_MVP_MATRIX] = [self.shaderProgram uniformIndex:@"mvpMatrix"];

	glEnable(GL_DEPTH_TEST);

    glGenVertexArraysOES(1, &_vertexArray);
    glBindVertexArrayOES(_vertexArray);

    glGenBuffers(1, &_vertexBuffer);
	glBindBuffer(GL_ARRAY_BUFFER, _vertexBuffer);
	glBufferData(GL_ARRAY_BUFFER, sizeof(cubeVertices), cubeVertices, GL_STATIC_DRAW);

    glEnableVertexAttribArray(GLKVertexAttribPosition);
    glVertexAttribPointer(GLKVertexAttribPosition,
                          3,
                          GL_FLOAT,
                          GL_FALSE,
                          8 * sizeof(GLfloat),
                          BUFFER_OFFSET(0));

    glEnableVertexAttribArray(GLKVertexAttribNormal);
    glVertexAttribPointer(GLKVertexAttribNormal,
                          3,
                          GL_FLOAT,
                          GL_FALSE,
                          8 * sizeof(GLfloat),
                          BUFFER_OFFSET(3 * sizeof(GLfloat)));

    glEnableVertexAttribArray(GLKVertexAttribTexCoord0);
    glVertexAttribPointer(GLKVertexAttribTexCoord0,
                          2,
                          GL_FLOAT,
                          GL_TRUE,
                          8 * sizeof(GLfloat),
                          BUFFER_OFFSET(6 * sizeof(GLfloat)));


}

- (void)tearDownGL {
	[EAGLContext setCurrentContext:self.context];
	glDeleteBuffers(1, &_vertexBuffer);
}

#pragma mark - Texture delegate method

- (void)textureCreatedWithTarget:(GLenum)target name:(GLuint)name {
    glActiveTexture(GL_TEXTURE0);
    glBindTexture(target, name);
    glTexParameterf(GL_TEXTURE_2D, GL_TEXTURE_WRAP_S, GL_CLAMP_TO_EDGE);
    glTexParameterf(GL_TEXTURE_2D, GL_TEXTURE_WRAP_T, GL_CLAMP_TO_EDGE);
}

#pragma mark - GLKViewController method overrides

- (void)update {
    CGRect bounds = self.view.bounds;

    GLfloat aspect = fabs(CGRectGetWidth(bounds) / CGRectGetHeight(bounds));
    GLKMatrix4 projectionMatrix =
    GLKMatrix4MakePerspective(GLKMathDegreesToRadians(50.0f),
                              aspect, 0.1f, 100.0f);

    GLKMatrix4 modelViewMatrix = GLKMatrix4MakeTranslation(0.0f, 0.0f, -3.5f);
    modelViewMatrix = GLKMatrix4Rotate(modelViewMatrix, _rotation, 1.f, 1.f, 1.f);

    _mvpMatrix = GLKMatrix4Multiply(projectionMatrix, modelViewMatrix);
    _rotation += self.timeSinceLastUpdate * 0.75;
}

#pragma mark - GLKView delegate methods

- (void)glkView:(GLKView *)view drawInRect:(CGRect)rect {
    glClearColor(0.2f, 0.2f, 0.2f, 1.0f);
    glClear(GL_COLOR_BUFFER_BIT | GL_DEPTH_BUFFER_BIT);

    glBindVertexArrayOES(_vertexArray);

    [self.shaderProgram useProgram];

    glUniformMatrix4fv(uniforms[UNIFORM_MVP_MATRIX], 1, 0, _mvpMatrix.m);
    glUniform1i(uniforms[UNIFORM_TEXTURE], 0);
    glDrawArrays(GL_TRIANGLES, 0, 36);
}

@end
