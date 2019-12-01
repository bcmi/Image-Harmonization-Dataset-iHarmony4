
#ifndef __Point_hh__
#define __Point_hh__

// Simple point template classes.  
// Probably only make sense for intrinsic types.

// 2D Points

template<class T>
class Point2D
{
public:
    Point2D () { x = 0; y = 0; }
    Point2D (T x, T y) { this->x = x; this->y = y; }
    T x,y;
};

template<class T>
inline int operator== (const Point2D<T>& a, const Point2D<T>& b) 
{ return (a.x == b.x) && (a.y == b.y); }

template<class T>
inline int operator!= (const Point2D<T>& a, const Point2D<T>& b) 
{ return (a.x != b.x) || (a.y != b.y); }

typedef Point2D<int> Pixel;

// 3D Points

template<class T>
class Point3D
{
public:
    Point3D () { x = 0; y = 0; z = 0; }
    Point3D (T x, T y) { this->x = x; this->y = y; this->z = z;}
    T x,y,z;
};

template<class T>
inline int operator== (const Point3D<T>& a, const Point3D<T>& b) 
{ return (a.x == b.x) && (a.y == b.y) && (a.z == b.z); }

template<class T>
inline int operator!= (const Point3D<T>& a, const Point3D<T>& b) 
{ return (a.x != b.x) || (a.y != b.y) || (a.z != b.z); }

typedef Point3D<int> Voxel;

#endif // __Point_hh__
