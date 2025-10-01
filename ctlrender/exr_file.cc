///////////////////////////////////////////////////////////////////////////
// Copyright (c) 2013 Academy of Motion Picture Arts and Sciences 
// ("A.M.P.A.S."). Portions contributed by others as indicated.
// All rights reserved.
// 
// A worldwide, royalty-free, non-exclusive right to copy, modify, create
// derivatives, and use, in source and binary forms, is hereby granted, 
// subject to acceptance of this license. Performance of any of the 
// aforementioned acts indicates acceptance to be bound by the following 
// terms and conditions:
//
//  * Copies of source code, in whole or in part, must retain the 
//    above copyright notice, this list of conditions and the 
//    Disclaimer of Warranty.
//
//  * Use in binary form must retain the above copyright notice, 
//    this list of conditions and the Disclaimer of Warranty in the
//    documentation and/or other materials provided with the distribution.
//
//  * Nothing in this license shall be deemed to grant any rights to 
//    trademarks, copyrights, patents, trade secrets or any other 
//    intellectual property of A.M.P.A.S. or any contributors, except 
//    as expressly stated herein.
//
//  * Neither the name "A.M.P.A.S." nor the name of any other 
//    contributors to this software may be used to endorse or promote 
//    products derivative of or based on this software without express 
//    prior written permission of A.M.P.A.S. or the contributors, as 
//    appropriate.
// 
// This license shall be construed pursuant to the laws of the State of 
// California, and any disputes related thereto shall be subject to the 
// jurisdiction of the courts therein.
//
// Disclaimer of Warranty: THIS SOFTWARE IS PROVIDED BY A.M.P.A.S. AND 
// CONTRIBUTORS "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, 
// BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY, FITNESS 
// FOR A PARTICULAR PURPOSE, AND NON-INFRINGEMENT ARE DISCLAIMED. IN NO 
// EVENT SHALL A.M.P.A.S., OR ANY CONTRIBUTORS OR DISTRIBUTORS, BE LIABLE 
// FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, RESITUTIONARY, 
// OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF 
// SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS 
// INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN 
// CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) 
// ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF 
// THE POSSIBILITY OF SUCH DAMAGE.
//
// WITHOUT LIMITING THE GENERALITY OF THE FOREGOING, THE ACADEMY 
// SPECIFICALLY DISCLAIMS ANY REPRESENTATIONS OR WARRANTIES WHATSOEVER 
// RELATED TO PATENT OR OTHER INTELLECTUAL PROPERTY RIGHTS IN THE ACADEMY 
// COLOR ENCODING SYSTEM, OR APPLICATIONS THEREOF, HELD BY PARTIES OTHER 
// THAN A.M.P.A.S., WHETHER DISCLOSED OR UNDISCLOSED.
///////////////////////////////////////////////////////////////////////////

#include "exr_file.hh"
#include <fstream>

#if defined(HAVE_OPENEXR)
#include <ImfInputFile.h>
#include <ImfOutputFile.h>
#include <ImfRgbaFile.h>
#include <ImfArray.h>
#include <ImfHeader.h>
#include <ImfChannelList.h>
#include <Iex.h>

bool exr_read_16(Imf::InputFile file, Imath::Box2i dataWindow, ctl::dpx::fb<float>* pixels)
{
  // exr read code based on example documentation
  // https://openexr.com/en/latest/ReadingAndWritingImageFiles.html#reading-an-image-file

  Imf::FrameBuffer frameBuffer;

  Imf::Array2D<half> rPixels;
  Imf::Array2D<half> gPixels;
  Imf::Array2D<half> bPixels;
  Imf::Array2D<half> aPixels;

  int width = dataWindow.max.x - dataWindow.min.x + 1;
  int height = dataWindow.max.y - dataWindow.min.y + 1;

  bool has_alpha = file.header().channels().findChannel("A");

  rPixels.resizeErase(height, width);
  gPixels.resizeErase(height, width);
  bPixels.resizeErase(height, width);

  // red
  frameBuffer.insert("R",            // name
    Imf::Slice(Imf::HALF,            // type
      (char*)(&rPixels[0][0] -       // base
        dataWindow.min.x -
        dataWindow.min.y * width),
      sizeof(rPixels[0][0]) * 1,     // xStride
      sizeof(rPixels[0][0]) * width, // yStride
      1, 1,                          // x/y sampling
      0.0));                         // fillValue

  // green
  frameBuffer.insert("G",            // name
    Imf::Slice(Imf::HALF,            // type
      (char*)(&gPixels[0][0] -       // base
        dataWindow.min.x -
        dataWindow.min.y * width),
      sizeof(gPixels[0][0]) * 1,     // xStride
      sizeof(gPixels[0][0]) * width, // yStride
      1, 1,                          // x/y sampling
      0.0));                         // fillValue

  // blue
  frameBuffer.insert("B",            // name
    Imf::Slice(Imf::HALF,            // type
      (char*)(&bPixels[0][0] -       // base
        dataWindow.min.x -
        dataWindow.min.y * width),
      sizeof(bPixels[0][0]) * 1,     // xStride
      sizeof(bPixels[0][0]) * width, // yStride
      1, 1,                          // x/y sampling
      0.0));                         // fillValue

  // alpha
  if (has_alpha) {
    aPixels.resizeErase(height, width);

    frameBuffer.insert("A",            // name
      Imf::Slice(Imf::HALF,            // type
        (char*)(&aPixels[0][0] -       // base
          dataWindow.min.x -
          dataWindow.min.y * width),
        sizeof(aPixels[0][0]) * 1,     // xStride
        sizeof(aPixels[0][0]) * width, // yStride
        1, 1,                          // x/y sampling
        1.0));                         // fillValue
  }

  file.setFrameBuffer(frameBuffer);
  file.readPixels(dataWindow.min.y, dataWindow.max.y);

  // copy data from Array2D back to RGBA interleaved buffer pixels
  int i = 0;
  float* p = pixels->ptr();
  for (int y = 0; y < height; y++)
  {
    for (int x = 0; x < width; x++)
    {
      p[i++] = rPixels[y][x];
      p[i++] = gPixels[y][x];
      p[i++] = bPixels[y][x];
      if (has_alpha) {
        p[i++] = aPixels[y][x];
      }
    }
  }

  return true;
}

bool exr_read_32(Imf::InputFile file, Imath::Box2i dataWindow, ctl::dpx::fb<float>* pixels)
{
  // exr read code based on example documentation
  // https://openexr.com/en/latest/ReadingAndWritingImageFiles.html#reading-an-image-file

  Imf::FrameBuffer frameBuffer;

  Imf::Array2D<float> rPixels;
  Imf::Array2D<float> gPixels;
  Imf::Array2D<float> bPixels;
  Imf::Array2D<float> aPixels;

  int width = dataWindow.max.x - dataWindow.min.x + 1;
  int height = dataWindow.max.y - dataWindow.min.y + 1;

  bool has_alpha = file.header().channels().findChannel("A");

  rPixels.resizeErase(height, width);
  gPixels.resizeErase(height, width);
  bPixels.resizeErase(height, width);

  // red
  frameBuffer.insert("R",            // name
    Imf::Slice(Imf::FLOAT,            // type
      (char*)(&rPixels[0][0] -       // base
        dataWindow.min.x -
        dataWindow.min.y * width),
      sizeof(rPixels[0][0]) * 1,     // xStride
      sizeof(rPixels[0][0]) * width, // yStride
      1, 1,                          // x/y sampling
      0.0));                         // fillValue

  // green
  frameBuffer.insert("G",            // name
    Imf::Slice(Imf::FLOAT,            // type
      (char*)(&gPixels[0][0] -       // base
        dataWindow.min.x -
        dataWindow.min.y * width),
      sizeof(gPixels[0][0]) * 1,     // xStride
      sizeof(gPixels[0][0]) * width, // yStride
      1, 1,                          // x/y sampling
      0.0));                         // fillValue

  // blue
  frameBuffer.insert("B",            // name
    Imf::Slice(Imf::FLOAT,            // type
      (char*)(&bPixels[0][0] -       // base
        dataWindow.min.x -
        dataWindow.min.y * width),
      sizeof(bPixels[0][0]) * 1,     // xStride
      sizeof(bPixels[0][0]) * width, // yStride
      1, 1,                          // x/y sampling
      0.0));                         // fillValue

  // alpha
  if (has_alpha) {
    aPixels.resizeErase(height, width);

    frameBuffer.insert("A",            // name
      Imf::Slice(Imf::FLOAT,            // type
        (char*)(&aPixels[0][0] -       // base
          dataWindow.min.x -
          dataWindow.min.y * width),
        sizeof(aPixels[0][0]) * 1,     // xStride
        sizeof(aPixels[0][0]) * width, // yStride
        1, 1,                          // x/y sampling
        1.0));                         // fillValue
  }

  file.setFrameBuffer(frameBuffer);
  file.readPixels(dataWindow.min.y, dataWindow.max.y);

  // copy data from Array2D back to RGBA interleaved buffer pixels
  int i = 0;
  float* p = pixels->ptr();
  for (int y = 0; y < height; y++)
  {
    for (int x = 0; x < width; x++)
    {
      p[i++] = rPixels[y][x];
      p[i++] = gPixels[y][x];
      p[i++] = bPixels[y][x];
      if (has_alpha) {
        p[i++] = aPixels[y][x];
      }
    }
  }

  return true;
}

bool exr_read(const char *name, float scale, ctl::dpx::fb<float> *pixels,
              format_t *format) {
	std::ifstream ins;
	unsigned int magic, endian;

	ins.open(name);

    if (!ins.good())
    {
      fprintf(stderr, "WARNING on line %d of file %s in function %s(): unable to open file %s\n",
        __LINE__, __FILE__, __FUNCTION__, name);
      return false;
    }

	ins.read((char *)&magic, sizeof(magic));
	endian=0x01020304;
	if(((unsigned char *)(&endian))[0]==0x01) {
		if(magic!=0x762f3101) {
			return 0;
		}
	} else {
		if(magic!=0x01312f76) {
			return 0;
		}
	}
	//////////////////////////
    
    Imf::InputFile file(name);
    Imath::Box2i dataWindow = file.header().dataWindow();
    format->data_window = dataWindow;
    format->is_data_window_set = true;
    
    if (file.header().channels().begin().channel().type == Imf::HALF)
        format->src_bps=16;
    else
        format->src_bps=32;
        
    int width = dataWindow.max.x - dataWindow.min.x + 1;
    int height = dataWindow.max.y - dataWindow.min.y + 1;

    bool has_alpha = file.header().channels().findChannel("A");

    pixels->init(width, height, has_alpha ? 4 : 3);
    Imf::PixelType pixelType = format->src_bps == 16 ? Imf::HALF : Imf::FLOAT;

    if (pixelType == Imf::HALF)
    {
      exr_read_16(file, dataWindow, pixels);
    }
    else if (pixelType == Imf::FLOAT)
    {
      exr_read_32(file, dataWindow, pixels);
    }      
    
    // scale pixels if a scale value has been specified
	if(scale==0.0 || scale==1.0) {
		return 1;
	}
    else
    {
      float* p = pixels->ptr();
      for (uint64_t i = 0; i < pixels->count(); i++) {
        *p = *p * scale;
        p++;
      }
    }

	return 1;
}

void exr_write(const char *name, float scale, const ctl::dpx::fb<float> &pixels,
               format_t *format, Compression *compression)
{
    if (format->bps != 32 && format->bps != 16) {
        THROW(Iex::ArgExc, "EXR files only support 16 or 32 bps at the moment.");
    }

    bool is_half = format->bps == 16 ? true : false;

    int depth = pixels.depth();
    int width = pixels.width();
    int height = pixels.height();
    float const* pixelPtr = pixels.ptr();

    // Do any scaling on a full float buffer
    ctl::dpx::fb<float> scaled_pixels;
    if (scale != 0.0 && scale != 1.0) {
        scaled_pixels.init(width, height, depth);
        scaled_pixels.alpha(1.0);

        const float* fIn = pixels.ptr();
        float* out = scaled_pixels.ptr();

        for (uint64_t i = 0; i < pixels.count(); i++) {
            *(out++) = *(fIn++) / scale;
        }
        pixelPtr = scaled_pixels.ptr();
    }

    // follow example exr writing code in documenation here:
    // https://openexr.com/en/latest/ReadingAndWritingImageFiles.html#writing-a-cropped-image

    // Generate header
    Imf::PixelType pixelType = is_half ? Imf::HALF : Imf::FLOAT;

    Imf::Header header(width, height);
    header.compression() = (Imf::Compression)compression->exrCompressionScheme;
    Imath::Box2i dataWindow;
    if (format->is_data_window_set)
    {
      dataWindow = format->data_window;
    }
    else
    {   
      dataWindow.min.x = 0;
      dataWindow.min.y = 0;
      dataWindow.max.x = width - 1;
      dataWindow.max.y = height - 1;
    }

#define USE_OLD_EXR_WRITE_CODE 1
#if USE_OLD_EXR_WRITE_CODE
    // do not set datawindow in output file
#else
    header.dataWindow() = dataWindow;
#endif

    header.channels().insert("R", Imf::Channel(pixelType));
    header.channels().insert("G", Imf::Channel(pixelType));
    header.channels().insert("B", Imf::Channel(pixelType));
    if (depth == 4)
        header.channels().insert("A", Imf::Channel(pixelType));

    Imf::OutputFile file(name, header);
    Imf::FrameBuffer frameBuffer;

    ctl::dpx::fb<half> half_pixels;
    if (is_half) {
        // Create new half buffer
        half_pixels.init(pixels.width(), pixels.height(), pixels.depth());
        half_pixels.alpha(1.0);

        // convert from float buffer to half buffer
        const float* fIn = pixelPtr;
        half* out = half_pixels.ptr();
        for (uint64_t i = 0; i < pixels.count(); i++) {
           *(out++) = half(*(fIn++));
        }

#if USE_OLD_EXR_WRITE_CODE
        half const* halfPixelPtr = half_pixels.ptr();

        int xstride = sizeof(*halfPixelPtr) * depth;
        int ystride = sizeof(*halfPixelPtr) * depth * width;
#else
        Imf::Array2D<half> rPixels;
        Imf::Array2D<half> gPixels;
        Imf::Array2D<half> bPixels;
        Imf::Array2D<half> aPixels;

        rPixels.resizeErase(height, width);
        gPixels.resizeErase(height, width);
        bPixels.resizeErase(height, width); 

        // copy data into Array2D from halfPixelPtr
        int i = 0;
        half* p = half_pixels.ptr();
        for (int y = 0; y < height; y++)
        {
          for (int x = 0; x < width; x++)
          {
            rPixels[y][x] = p[i++];
            gPixels[y][x] = p[i++];
            bPixels[y][x] = p[i++];
            if (depth == 4) {
              aPixels[y][x] = p[i++];
            }
          }
        }
#endif

        // Insert the half buffer into the framebuffer
#if USE_OLD_EXR_WRITE_CODE
        frameBuffer.insert("R", Imf::Slice(pixelType, (char*) halfPixelPtr, xstride, ystride));
        frameBuffer.insert("G", Imf::Slice(pixelType, (char*)(halfPixelPtr + 1), xstride, ystride));
        frameBuffer.insert("B", Imf::Slice(pixelType, (char*)(halfPixelPtr + 2), xstride, ystride));
        if (depth == 4)
            frameBuffer.insert("A", Imf::Slice(pixelType, (char*)(halfPixelPtr + 3), xstride, ystride));
#else
        frameBuffer.insert(
          "R", // name
          Imf::Slice(
            Imf::HALF,                        // type
            (char*)&rPixels[0][0],            // base
            sizeof(rPixels[0][0]) * 1,        // xStride
            sizeof(rPixels[0][0]) * width));  // yStride

        frameBuffer.insert(
          "G", // name
          Imf::Slice(
            Imf::HALF,                        // type
            (char*)&gPixels[0][0],            // base
            sizeof(gPixels[0][0]) * 1,        // xStride
            sizeof(gPixels[0][0])* width));  // yStride

        frameBuffer.insert(
          "B", // name
          Imf::Slice(
            Imf::HALF,                        // type
            (char*)&bPixels[0][0],            // base
            sizeof(bPixels[0][0]) * 1,        // xStride
            sizeof(bPixels[0][0])* width));  // yStride
#endif

    }
    else {
        // No conversion needed so insert the float buffer into the frambuffer
        int xstride = sizeof(*pixelPtr) * depth;
        int ystride = sizeof(*pixelPtr) * depth * width;

        frameBuffer.insert("R", Imf::Slice(pixelType, (char*)pixelPtr, xstride, ystride));
        frameBuffer.insert("G", Imf::Slice(pixelType, (char*)(pixelPtr + 1), xstride, ystride));
        frameBuffer.insert("B", Imf::Slice(pixelType, (char*)(pixelPtr + 2), xstride, ystride));
        if (depth == 4)
            frameBuffer.insert("A", Imf::Slice(pixelType, (char*)(pixelPtr + 3), xstride, ystride));
    }


    file.setFrameBuffer(frameBuffer);
#if USE_OLD_EXR_WRITE_CODE
    file.writePixels(height);
#else
    file.writePixels(dataWindow.max.y - dataWindow.min.y + 1);
#endif

    return;
}

#else

bool exr_read(const char *name, float scale,
              ctl::dpx::fb<float> *pixels,
              format_t *bpp) {
//    fprintf(stderr, "WARNING on line %d of file %s in function %s(): exr_read() function was called but OpenEXR library was not found\n",
//    __LINE__, __FILE__, __FUNCTION__);
	return FALSE;
}

void exr_write(const char *name, float scale,
               const ctl::dpx::fb<float> &pixels,
               format_t *format,
               Compression *compression) {
//    fprintf(stderr, "WARNING on line %d of file %s in function %s(): exr_write() function was called but OpenEXR library was not found\n",
//    __LINE__, __FILE__, __FUNCTION__);
}

#endif


