{***********************************************************************************************************************
 *
 * TERRA Game Engine
 * ==========================================
 *
 * Copyright (C) 2003, 2014 by S�rgio Flores 
 *
 ***********************************************************************************************************************
 *
 * Licensed under the Apache License, Version 2.0 (the "License"); you may not use this file except in compliance with
 * the License. You may obtain a copy of the License at
 *
 *     http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software distributed under the License is distributed on
 * an "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied. See the License for the
 * specific language governing permissions and limitations under the License.
 *
 **********************************************************************************************************************
 * TERRA_
 * Implements a Quaternion class (and Quaternion operations)
 ***********************************************************************************************************************
}
Unit TERRA_Quaternion;
{$I terra.inc}

Interface
Uses TERRA_Math, TERRA_Vector3D, TERRA_Matrix4x4;

Type
  PQuaternion = ^Quaternion;
  Quaternion=Packed {$IFDEF USE_OLD_OBJECTS}Object{$ELSE}Record{$ENDIF}
    X:Single;
    Y:Single;
    Z:Single;
    W:Single;

    Function Equals(Const B:Quaternion):Boolean;

    // Returns a normalized Quaternion
    Procedure Normalize;

    {$IFDEF BENCHMARK}
    Procedure TransformSSE(Const M:Matrix4x4);
    Procedure NormalizeSSE;
    {$ENDIF}

    Procedure Transform(Const M:Matrix4x4);

    Procedure Add(Const B:Quaternion);
    Procedure Subtract(Const B:Quaternion);

    Function Length:Single;
  End;

  Color4F = Quaternion;

Const
  QuaternionOne:Quaternion=(X:1.0; Y:1.0; Z:1.0; W:1.0);
  QuaternionZero:Quaternion=(X:0.0; Y:0.0; Z:0.0; W:1.0);

Function QuaternionCreate(Const X,Y,Z,W:Single):Quaternion;Overload;
Function QuaternionCreate(Const V:Vector3D):Quaternion;Overload;

// Creates a quaterion with specified rotation
Function QuaternionRotation(Const Rotation:Vector3D):Quaternion;

// Returns a Matrix4x4 representing the Quaternion
Function QuaternionMatrix4x4(Const Quaternion:Quaternion):Matrix4x4;

Function QuaternionFromRotationMatrix4x4(Const M:Matrix4x4):Quaternion;

Function QuaternionFromToRotation(Const Src,Dest:Vector3D):Quaternion;

// Slerps two Quaternions
Function QuaternionSlerp(A,B:Quaternion; Const T:Single):Quaternion;
{$IFDEF BENCHMARK}
Function QuaternionSlerpSSE(A,B:Quaternion; Const T:Single):Quaternion;
{$ENDIF}

// Returns the conjugate of a Quaternion
Function QuaternionConjugate(Const Q:Quaternion):Quaternion;

// Returns the norm of a Quaternion
Function QuaternionNorm(Const Q:Quaternion):Single;

// Returns the inverse of a Quaternion
Function QuaternionInverse(Const Q:Quaternion):Quaternion;

// Multiplies two Quaternions
Function QuaternionMultiply(Const Ql,Qr:Quaternion):Quaternion;

Function QuaternionAdd(Const A,B:Quaternion):Quaternion;

Function QuaternionScale(Const Q:Quaternion; Const Scale:Single):Quaternion;

Function QuaternionFromBallPoints(Const arcFrom,arcTo:Vector3D):Quaternion;
Procedure QuaternionToBallPoints(Q:Quaternion; Var arcFrom,arcTo:Vector3D);

Function QuaternionFromAxisAngle(Const Axis:Vector3D; Const Angle:Single):Quaternion;

Function QuaternionToEuler(Const Q:Quaternion):Vector3D;

Function QuaternionLookRotation(lookAt, up:Vector3D):Quaternion;

Function QuaternionTransform(Const Q:Quaternion; Const V:Vector3D):Vector3D;

// Returns the dot product between two vectors
Function QuaternionDot(Const A,B:Quaternion):Single; {$IFDEF FPC}Inline;{$ENDIF}

Implementation
Uses Math{$IFDEF SSE},TERRA_SSE{$ENDIF}{$IFDEF NEON_FPU},TERRA_NEON{$ENDIF};

Function QuaternionCreate(Const X,Y,Z,W:Single):Quaternion;
Begin
  Result.X := X;
  Result.Y := Y;
  Result.Z := Z;
  Result.W := W;
End;

Function QuaternionCreate(Const V:Vector3D):Quaternion;
Begin
  Result.X := V.X;
  Result.Y := V.Y;
  Result.Z := V.Z;
  Result.W := 1.0;
End;

Function QuaternionTransform(Const Q:Quaternion; Const V:Vector3D):Vector3D;
Var
  M:Matrix4x4;
Begin
  M := QuaternionMatrix4x4(Q);
  Result := M.Transform(V);
End;

Function Quaternion.Length:Single;
Begin
  Result := Sqrt(Sqr(X) + Sqr(Y) + Sqr(Z) + Sqr(W));
End;

Function Quaternion.Equals(Const B:Quaternion):Boolean;
Begin
  Result := (Self.X=B.X) And (Self.Y=B.Y) And(Self.Z=B.Z) And(Self.W=B.W);
End;

Function QuaternionDot(Const A,B:Quaternion):Single; {$IFDEF FPC}Inline;{$ENDIF}
Begin
  {$IFDEF NEON_FPU}
  Result := dot4_neon_hfp(@A,@B);
  {$ELSE}
  Result := (A.X*B.X)+(A.Y*B.Y)+(A.Z*B.Z)+(A.W*B.W);
  {$ENDIF}
End;

Function QuaternionLookRotation(lookAt, up:Vector3D):Quaternion;
Var
  m00,m01, m02, m10, m11, m12, m20, m21, m22:Single;
  right:Vector3D;
  w4_recip:Single;
Begin
	VectorOrthoNormalize(lookAt, up);
  lookAt.Normalize();
	right := VectorCross(up, lookAt);

  m00 := right.x;
  m01 := up.x;
  m02 := lookAt.x;
  m10 := right.y;
  m11 := up.y;
  m12 := lookAt.y;
  m20 := right.z;
  m21 := up.z;
  m22 := lookAt.z;

	Result.w := Sqrt(1.0 + m00 + m11 + m22) * 0.5;
	w4_recip := 1.0 / (4.0 * Result.w);
	Result.x := (m21 - m12) * w4_recip;
	Result.y := (m02 - m20) * w4_recip;
	Result.z := (m10 - m01) * w4_recip;
End;

Function QuaternionFromToRotation(Const Src,Dest:Vector3D):Quaternion;
{Var
  Temp:Vector3D;
Begin
  Temp := VectorCross(A, B);
  Result.X := Temp.X;
  Result.Y := Temp.Y;
  Result.Z := Temp.Z;
  Result.W := Sqrt(Sqr(A.Length) * Sqr(B.Length)) + VectorDot(A, B);
  Result.Normalize();
End;}
Var
  D,S,Invs:Single;
  axis, v0,v1,c:Vector3D;
Begin
  v0 := Src;
  v1 := dest;
  v0.Normalize();
  v1.Normalize();

  d := VectorDot(v0, v1);
  // If dot == 1, vectors are the same
  If (d >= 1.0) Then
  Begin
    Result := QuaternionZero;
    Exit;
  End;

  If (d < (1e-6 - 1.0)) Then
  Begin
    // Generate an axis
    axis := VectorCross(VectorCreate(1,0,0), Src);
    If (axis.Length<=0) Then // pick another if colinear
      axis := VectorCross(VectorCreate(0,1,0), Src);
    Axis.Normalize();
    Result := QuaternionFromAxisAngle(Axis, PI);
  End Else
  Begin
    s := Sqrt( (1+d)*2 );
    invs := 1 / s;

    c := VectorCross(v0, v1);

    Result.x := c.x * invs;
    Result.y := c.y * invs;
    Result.z := c.z * invs;
    Result.w := s * 0.5;
		Result.Normalize();
  End;
End;

Function QuaternionRotation(Const Rotation:Vector3D):Quaternion;
Var
  cos_z_2, cos_y_2, cos_x_2:Single;
  sin_z_2, sin_y_2, sin_x_2:Single;
Begin
  cos_z_2 := Cos(0.5 * Rotation.Z);
  cos_y_2 := Cos(0.5 * Rotation.y);
  cos_x_2 := Cos(0.5 * Rotation.x);

  sin_z_2 := Sin(0.5 * Rotation.z);
  sin_y_2 := Sin(0.5 * Rotation.y);
  sin_x_2 := Sin(0.5 * Rotation.x);

	// and now compute Quaternion
	Result.W := cos_z_2*cos_y_2*cos_x_2 + sin_z_2*sin_y_2*sin_x_2;
  Result.X := cos_z_2*cos_y_2*sin_x_2 - sin_z_2*sin_y_2*cos_x_2;
	Result.Y := cos_z_2*sin_y_2*cos_x_2 + sin_z_2*cos_y_2*sin_x_2;
  Result.Z := sin_z_2*cos_y_2*cos_x_2 - cos_z_2*sin_y_2*sin_x_2;

  Result.Normalize;
End;

Function QuaternionFromRotationMatrix4x4(Const M:Matrix4x4):Quaternion;
Var
  w4:Double;
Function Index(I,J:Integer):Integer;
Begin
  Result := J*4 + I;
End;
Begin
	Result.w := Sqrt(1.0 + M.V[0] + M.V[5] + M.V[10]) / 2.0;
	w4 := (4.0 * Result.w);
	Result.x := (M.V[Index(2,1)] - M.V[Index(1,2)]) / w4 ;
	Result.y := (M.V[Index(0,2)] - M.V[Index(2,0)]) / w4 ;
	Result.z := (M.V[Index(1,0)] - M.V[Index(0,1)]) / w4 ;
End;

Function QuaternionMatrix4x4(Const Quaternion:Quaternion):Matrix4x4;
Var
  Q:TERRA_Quaternion.Quaternion;
Begin
  Q := Quaternion;
  Q.Normalize;

  Result.V[0]:= 1.0 - 2.0*Q.Y*Q.Y -2.0 *Q.Z*Q.Z;
  Result.V[1]:= 2.0 * Q.X*Q.Y + 2.0 * Q.W*Q.Z;
  Result.V[2]:= 2.0 * Q.X*Q.Z - 2.0 * Q.W*Q.Y;
  Result.V[3] := 0;

  Result.V[4]:= 2.0 * Q.X*Q.Y - 2.0 * Q.W*Q.Z;
  Result.V[5]:= 1.0 - 2.0 * Q.X*Q.X - 2.0 * Q.Z*Q.Z;
  Result.V[6]:= 2.0 * Q.Y*Q.Z + 2.0 * Q.W*Q.X;
  Result.V[7] := 0;

  Result.V[8] := 2.0 * Q.X*Q.Z + 2.0 * Q.W*Q.Y;
  Result.V[9] := 2.0 * Q.Y*Q.Z - 2.0 * Q.W*Q.X;
  Result.V[10] := 1.0 - 2.0 * Q.X*Q.X - 2.0 * Q.Y*Q.Y;
  Result.V[11] := 0;

  Result.V[12] := 0.0;
  Result.V[13] := 0.0;
  Result.V[14] := 0.0;
  Result.V[15] := 1.0;
End;

Function QuaternionMultiply(Const Ql,Qr:Quaternion):Quaternion;
Begin
  Result.W := qL.W * qR.W - qL.X * qR.X - qL.Y * qR.Y - qL.Z * qR.Z;
  Result.X := qL.W * qR.X + qL.X * qR.W + qL.Y * qR.Z - qL.Z * qR.Y;
  Result.Y := qL.W * qR.Y + qL.Y * qR.W + qL.Z * qR.X - qL.X * qR.Z;
  Result.Z := qL.W * qR.Z + qL.Z * qR.W + qL.X * qR.Y - qL.Y * qR.X;
End;

{$IFDEF SSE}
{$IFDEF BENCHMARK}
Procedure Quaternion.NormalizeSSE; Register;
{$ELSE}
Procedure Quaternion.Normalize; Register;
{$ENDIF}
Asm
  movups xmm0, [eax]
  movaps xmm2, xmm0     // store copy of the vector
  mulps xmm0, xmm0      // xmm0 = (sqr(x), sqr(y), sqr(z), sqr(w))
  movaps xmm1, xmm0
  movaps xmm3, xmm0
  shufps xmm1, xmm1, 55h  // xmm1 = (sqr(y), sqr(y), sqr(y), sqr(y))
  addps xmm1, xmm0        // add both
  shufps xmm0, xmm0, 0AAh  // xmm1 = (sqr(z), sqr(z), sqr(z), sqr(z))
  addps xmm0, xmm1        // sum x + y + z

  shufps xmm3, xmm3, 0FFh  // xmm2 = (sqr(w), sqr(w), sqr(w), sqr(w))
  addps xmm0, xmm3        // sum all

  shufps xmm0, xmm0, 0h  // broadcast length
  xorps xmm1, xmm1
  ucomiss xmm0, xmm1    // check for zero length
  je @@END
  rsqrtps xmm0, xmm0       // get reciprocal of length of vector
  mulps xmm2, xmm0      // normalize

  movups [eax], xmm2   // store normalized result
@@END:
End;

{$ENDIF}

{$IFDEF BENCHMARK}{$UNDEF SSE}{$ENDIF}

{$IFNDEF SSE}
Procedure Quaternion.Normalize;
Var
  Len:Single;
{$IFDEF NEON_FPU}
  Temp:Quaternion;
{$ENDIF}
Begin
{$IFDEF NEON_FPU}
  Temp := Self;
  normalize4_neon(@Temp, @Self);
{$ELSE}
  Len := Sqrt(Sqr(X) + Sqr(Y) + Sqr(Z) + Sqr(W));
  If (Len<=0) Then
    Exit;

  Len := 1.0 / Len;
  X := X * Len;
  Y := Y * Len;
  Z := Z * Len;
  W := W * Len;
{$ENDIF}
End;

{$IFDEF BENCHMARK}
{$ENDIF}
{$ENDIF}

{$IFDEF BENCHMARK}{$DEFINE SSE}{$ENDIF}

Function QuaternionSlerp(A,B:Quaternion; Const T:Single):Quaternion;
Var
  Theta, Sine, Beta, Alpha:Single;
  Cosine:Single;
Begin
  Cosine := a.x*b.x + a.y*b.y + a.z*b.z + a.w*b.w;
  Cosine := Abs(Cosine);

  If ((1-cosine)>Epsilon) Then
  Begin
    Theta := ArcCos(cosine);
  	Sine := Sin(theta);

  	Beta := Sin((1-t)*theta) / sine;
  	Alpha := Sin(t*theta) / sine;
  End Else
  Begin
    Beta := (1.0 - T);
    Alpha := T;
  End;

  Result.X := A.X * Beta + B.X * Alpha;
  Result.Y := A.Y * Beta + B.Y * Alpha;
  Result.Z := A.Z * Beta + B.Z * Alpha;
  Result.W := A.W * Beta + B.W * Alpha;
End;

Procedure Quaternion.Add(Const B:Quaternion);
Begin
  X := X + B.X;
  Y := Y + B.Y;
  Z := Z + B.Z;
End;

Procedure Quaternion.Subtract(Const B:Quaternion);
Begin
  X := X - B.X;
  Y := Y - B.Y;
  Z := Z - B.Z;
End;

Function QuaternionAdd(Const A,B:Quaternion):Quaternion;
Begin
  With Result Do
  Begin
    X := A.X + B.X;
    Y := A.Y + B.Y;
    Z := A.Z + B.Z;
  End;
End;

Function QuaternionScale(Const Q:Quaternion; Const Scale:Single):Quaternion;
Begin
  With Result Do
  Begin
    X := Q.X * Scale;
    Y := Q.Y * Scale;
    Z := Q.Z * Scale;
  End;
End;

Function QuaternionFromBallPoints(Const arcFrom,arcTo:Vector3D):Quaternion;
Begin
  Result.X := arcFrom.Y * arcTo.Z - arcFrom.Z * arcTo.Y;
  Result.Y := arcFrom.Z * arcTo.X - arcFrom.X * arcTo.Z;
  Result.Z := arcFrom.X * arcTo.Y - arcFrom.Y * arcTo.X;
  Result.W := arcFrom.X * arcTo.X + arcFrom.Y * arcTo.Y + arcFrom.Z * arcTo.Z;
End;

Procedure QuaternionToBallPoints(Q:Quaternion; Var arcFrom,arcTo:Vector3D);
Var
  S:Single;
Begin
  S := Sqrt(Sqr(Q.X) + Sqr(Q.Y));

  If s=0 Then
    arcFrom:=VectorCreate(0.0, 1.0, 0.0)
  Else
    arcFrom:=VectorCreate(-Q.Y/S, Q.X/S, 0.0);

  arcTo.X := (Q.W * arcFrom.X) - (Q.Z * arcFrom.Y);
  arcTo.Y := (Q.W * arcFrom.Y) + (Q.Z * arcFrom.X);
  arcTo.Z := (Q.X * arcFrom.Y) - (Q.Y * arcFrom.X);

  If Q.W<0.0 Then
    arcFrom := VectorCreate(-arcFrom.X, -arcFrom.Y, 0.0);
End;

Function QuaternionConjugate(Const Q:Quaternion):Quaternion;
Begin
  Result.X :=  -Q.X;
  Result.Y := -Q.Y;
  Result.Z := -Q.Z;
  Result.W := Q.W;
End;

Function QuaternionNorm(Const Q:Quaternion):Single;
Begin
  Result := (Q.W*Q.W)+(Q.Z*Q.Z)+(Q.Y*Q.Y)+(Q.X*Q.X);
End;

Function QuaternionInverse(Const Q:Quaternion):Quaternion;
Var
  N:Single;
Begin
  Result := QuaternionConjugate(Q);
  N := QuaternionNorm(Result);
  Result.X := Result.X/N;
  Result.Y := Result.Y/N;
  Result.Z := Result.Z/N;
  Result.W := Result.W/N;
End;

{$IFDEF SSE}
{$IFDEF BENCHMARK}
Procedure Quaternion.TransformSSE(Const M:Matrix4x4); Register;
{$ELSE}
Procedure Quaternion.Transform(Const M:Matrix4x4); Register;
{$ENDIF}
Asm
  // copy vector, Matrix4x4 and result vector to registers
  mov ecx, eax
  mov edx, M

  movups xmm4, [edx]
  movups xmm5, [edx+$10]
  movups xmm6, [edx+$20]
  movups xmm7, [edx+$30]

  // calc x * m_1X
  movss xmm0, [ecx]
  shufps xmm0, xmm0, 0

  //mulps xmm0, [edx]
  mulps xmm0, xmm4

  // calc y * m_2X
  movss xmm1, [ecx+4]
  shufps xmm1, xmm1, 0

  //mulps xmm1, [edx+16]
  mulps xmm1, xmm5

  // calc z * m_3X
  movss xmm2, [ecx+8]
  shufps xmm2, xmm2, 0

  //mulps xmm2, [edx+32]
  mulps xmm2, xmm6

  // calc w * m_3X
  movss xmm3, [ecx+12]
  shufps xmm3, xmm3, 0

  //mulps xmm3, [edx+48]
  mulps xmm3, xmm7

  // calc final result
  addps xmm0, xmm1
  addps xmm2, xmm3
  addps xmm0, xmm2

  // save result
  movups [eax], xmm0
End;
{$ENDIF}

{$IFDEF BENCHMARK}{$UNDEF SSE}{$ENDIF}

{$IFNDEF SSE}
Procedure Quaternion.Transform(Const M:Matrix4x4); {$IFDEF FPC}Inline;{$ENDIF}
Var
  QX,QY,QZ,QW:Single;
{$IFDEF NEON_FPU}
  Temp:Quaternion;
{$ENDIF}
Begin
{$IFDEF NEON_FPU}
  Temp := Self;
  matvec4_neon(@M,@Temp,@Self);
{$ELSE}
  QX := X;
  QY := Y;
  QZ := Z;
  QW := W;

  X := QX*M.V[0] + QY*M.V[4] + QZ*M.V[8]  + QW*M.V[12];
  Y := QX*M.V[1] + QY*M.V[5] + QZ*M.V[9]  + QW*M.V[13];
  Z := QX*M.V[2] + QY*M.V[6] + QZ*M.V[10] + QW*M.V[14];
  W := QX*M.V[3] + QY*M.V[7] + QZ*M.V[11] + QW*M.V[15];
{$ENDIF}
End;
{$ENDIF}

//! converts from a normalized axis - angle pair rotation to a Quaternion
Function QuaternionFromAxisAngle(Const Axis:Vector3D; Const Angle:Single):Quaternion;
Var
  S:Single;
Begin
  S := Sin(Angle/2);
  Result.X := Axis.X * S;
  Result.Y := Axis.Y * S;
  Result.Z := Axis.Z * S;
  Result.W := Cos(angle/2);
End;

Function QuaternionToEuler(Const Q:Quaternion):Vector3D;
Var
  sqx, sqy, sqz:Single;
Begin
{  Result.X := Atan2(2 * q.Y * q.W - 2 * q.X * q.Z,
 	                1 - 2* Pow(q.Y, 2) - 2*Pow(q.Z, 2)   );

  Result.Y := Arcsin(2*q.X*q.Y + 2*q.Z*q.W);

  Result.Z := Atan2(2*q.X*q.W-2*q.Y*q.Z,
 	                1 - 2*Pow(q.X, 2) - 2*Pow(q.Z, 2)     );

  If (q.X*q.Y + q.Z*q.W = 0.5) Then
  Begin
    Result.X := (2 * Atan2(q.X,q.W));
 	  Result.Z := 0;
  End Else
  If (q.X*q.Y + q.Z*q.W = -0.5) Then
  Begin
    Result.X := (-2 * Atan2(q.X, q.W));
    Result.Z := 0;
  End;}

	sqx := Sqr(Q.X);
	sqy := Sqr(Q.Y);
	sqz := Sqr(Q.Z);

  Result.x := atan2(2 * (Q.z*Q.y + Q.x*Q.W), 1 - 2*(sqx + sqy));
  Result.y := arcsin(-2 * (Q.x*Q.z - Q.y*Q.W));
  Result.z := atan2(2 * (Q.x*Q.y + Q.z*Q.W), 1 - 2*(sqy + sqz));
End;

End.
