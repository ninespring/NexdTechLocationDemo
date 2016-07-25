//
//  locate_code_base.h
//  NexdTechLocationEngine
//
//  Created by Ninespring on 16/4/28.
//  Copyright © 2016年 Ninespring. All rights reserved.
//


#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <math.h>

struct Matrix{
    int row;
    int col;
    double **matrix;
};





//Display the Matrix Content
void dispMatrix(struct Matrix input);

//Loading Data Into Matrix Formation

int splitLineCount(char*);


// Count Rows And Columns Number in Text-format Files
int* countRowAndColumn(char *filename);

// Count Columns Number in Text-Format Files
int splitLineCount(char *line_);

//Loading Matrix Data into Struct Matrix
struct Matrix loadToStruct(char *file);

///////////////////////////////////////////////////////////////////////////////////



//Generate Location Engine Matrix

struct Matrix generateEngine(struct Matrix wp, struct Matrix optparam);

// Free Matrix Struct

struct Matrix freeMatrix(struct Matrix engine);




///////////////////////////////////////////////////////////////////////////////////


// Locate Algorithm

// Argmax Funciton For Searching the best match candidate
int argmax(double *prob, int len);

// POSITION LOCATING METHOD

int locatePosIndex(struct Matrix engine, struct Matrix optparam, double *input_array);