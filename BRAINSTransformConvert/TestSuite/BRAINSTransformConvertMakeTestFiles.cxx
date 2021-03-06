#include "itkIO.h"
#include "GenericTransformImage.h"
#include "itkVersorRigid3DTransform.h"
#include "itkScaleVersor3DTransform.h"
#include "itkScaleSkewVersor3DTransform.h"
#include "itkAffineTransform.h"
#include "itkBSplineDeformableTransform.h"
#include "itkTransformFileWriter.h"
#include "itkTransformFileReader.h"
#include "itkImageRegionIterator.h"
#include "vnl/vnl_random.h"

#if !defined( _WIN32 )
#include <unistd.h>
#else
#include <process.h>
inline int getpid()
{
  return _getpid();
}
#endif

template <class TTransform>
typename TTransform::Pointer
CreateTransform()
{
  typename TTransform::Pointer rval =
    TTransform::New();
  rval->SetIdentity();
  return rval;
}

int main(int argc, char **argv)
{
  if(argc < 2)
    {
    std::cerr << "Missing working directory argument" << std::endl;
    return EXIT_FAILURE;
    }
  VersorRigid3DTransformType::Pointer versorRigidTransform
    = CreateTransform<VersorRigid3DTransformType>();
  VersorRigid3DTransformType::InputPointType center;
  VersorRigid3DTransformType::AxisType axis;

  center[0] = 0.25;  center[1] = -0.25;  center[2] = 0.333;
  versorRigidTransform->SetCenter(center);

  axis[0] = 0.0; axis[1] = 1.0; axis[2] = 0.0;
  versorRigidTransform->SetRotation(axis,1.5);

  std::string versorRigidName(argv[1]);
  versorRigidName += "/VersorRigidTransform.txt";
  itk::WriteTransformToDisk(versorRigidTransform.GetPointer(), versorRigidName);

  ScaleVersor3DTransformType::Pointer scaleVersorTransform =
    CreateTransform<ScaleVersor3DTransformType>();
  ScaleVersor3DTransformType::OutputVectorType translation;

  translation[0] = 0.5; translation[1] = -0.6; translation[2] = 0.73;
  scaleVersorTransform->SetTranslation(translation);

  center[0] = -0.5; center[1] = 0.8; center[2] = 0.99;
  scaleVersorTransform->SetCenter(center);

  axis[0] = -1.0; axis[1] = 0.0; axis[2] = 0.0;
  scaleVersorTransform->SetRotation(axis,0.5723);
  ScaleVersor3DTransformType::ScaleVectorType scale;

  scale[0] = .75; scale[1] = 1.1; scale[2] = 0.3333;
  scaleVersorTransform->SetScale(scale);

  std::string scaleVersorName(argv[1]);
  scaleVersorName += "/ScaleVersorTransform.txt";
  itk::WriteTransformToDisk(scaleVersorTransform,scaleVersorName);

  ScaleSkewVersor3DTransformType::Pointer scaleSkewVersorTransform = 
    CreateTransform<ScaleSkewVersor3DTransformType>();
  translation[0] = -0.5; translation[1] = 0.6; translation[2] = -0.73;
  scaleSkewVersorTransform->SetTranslation(translation);

  center[0] = 0.7; center[1] = -0.8; center[2] = 0.97;
  scaleSkewVersorTransform->SetCenter(center);

  axis[0] = 0.0; axis[1] = 1.0; axis[2] = 0.0;
  scaleSkewVersorTransform->SetRotation(axis,0.993);

  scale[0] = .33; scale[1] = .5; scale[2] = 0.666;
  scaleSkewVersorTransform->SetScale(scale);

  std::string scaleSkewVersorName(argv[1]);
  scaleSkewVersorName += "/ScaleSkewVersorTransform.txt";
  itk::WriteTransformToDisk(scaleSkewVersorTransform,scaleSkewVersorName);

  AffineTransformType::Pointer affineTransform =
    CreateTransform<AffineTransformType>();

  translation[0] = -1.5; translation[1] = -0.7; translation[2] = -0.02;
  affineTransform->Translate(translation);

  center[0] = -0.77; center[1] = 0.88; center[2] = -0.97;
  affineTransform->SetCenter(center);

  axis[0] = 1.0; axis[1] = 0.0; axis[2] = 0.0;
  affineTransform->Rotate3D(axis,0.993);

  scale[0] = .65; scale[1] = 1.3; scale[2] = 0.9;
  affineTransform->Scale(scale);

  affineTransform->Shear(0,1,0.25);
  affineTransform->Shear(1,0,0.75);
  affineTransform->Shear(1,2,0.35);

  std::string affineName(argv[1]);
  affineName += "/AffineTransform.txt";
  itk::WriteTransformToDisk(affineTransform,affineName);

  BSplineTransformType::Pointer bsplineTransform =
    CreateTransform<BSplineTransformType>();

  translation[0] = -1.0; translation[1] = 0.6; translation[2] = -0.5;
  affineTransform->Translate(translation);

  center[0] = 0.77; center[1] = -0.8; center[2] = 0.03;
  affineTransform->SetCenter(center);

  axis[0] = 0.0; axis[1] = -1.0; axis[2] = 0.0;
  affineTransform->Rotate3D(axis,0.45);

  scale[0] = .8; scale[1] = .5; scale[2] = 0.3;
  affineTransform->Scale(scale);

  affineTransform->Shear(0,1,0.3);
  affineTransform->Shear(1,0,0.4);
  affineTransform->Shear(1,2,0.5);

  bsplineTransform->SetBulkTransform(affineTransform.GetPointer());

  std::string bsplineName(argv[1]);
  bsplineName += "/BSplineDeformableTransform.txt";
  itk::WriteTransformToDisk(bsplineTransform,bsplineName);

  typedef itk::Image<signed short,3> ImageType;
  ImageType::RegionType              region;
  ImageType::RegionType::SizeType    size;
  ImageType::RegionType::IndexType   index;
  ImageType::SpacingType             spacing;
  ImageType::PointType               origin;

  size[0] = size[1] = size[2] = 10;
  region.SetSize(size);
  index[0] = index[1] = index[2] = 0;
  region.SetSize(size);
  region.SetIndex(index);
  spacing[0] = spacing[1] = spacing[2] = 2.0;
  origin[0] = -10; origin[1] = -10; origin[10] = 10;

  ImageType::Pointer testImage =
    itkUtil::AllocateImageFromRegionAndSpacing<ImageType>(region,spacing);

  vnl_random randgen;
  randgen.reseed( getpid() );

  for(itk::ImageRegionIterator<ImageType> it(testImage,testImage->GetLargestPossibleRegion());
      !it.IsAtEnd(); ++it)
    {
    it.Set(static_cast<ImageType::PixelType>(randgen.lrand32(32767)));
    }

  std::string testImageName(argv[1]);
  testImageName += "/TransformConvertTestImage.nii.gz";
  itkUtil::WriteImage<ImageType>(testImage,testImageName);
  return EXIT_SUCCESS;
}
