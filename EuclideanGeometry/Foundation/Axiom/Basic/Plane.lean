import EuclideanGeometry.Foundation.Axiom.Basic.Vector

/-!
# Euclidean Plane

This file defines the Euclidean Plane as an affine space, which admits an action of the standard inner product real vector space of dimension two.

## Important definitions

* `EuclideanPlane` : the class of Euclidean Plane

## Notation

* `VEC A B` : the vector `B -ᵥ A` in `Vec`

## Implementation Notes

For simplicity, we use the standard inner product real vector space of dimension two as the underlying `SeminormedAddCommGroup` of the `NormedAddTorsor` in the definition of `EuclideanPlane`.

Thus we define `EuclideanPlane P` as `NormedAddTorsor (ℝ × ℝ) P` and present instances involving `EuclideanPlane`.

## Further Works

The current definition is far from being general enough. Roughly speaking, it suffices to define the Euclidean Plane to be a `NormedAddTorsor` over any 2 dimensional normed real inner product spaces `V` with a choice of an orientation on `V`, rather than over the special `ℝ × ℝ`. All further generalizations in this file should be done together with Vector.lean.

-/

noncomputable section
namespace EuclidGeom

/- Define Euclidean plane as normed vector space over ℝ of dimension 2 -/
class EuclideanPlane (P : Type _) extends MetricSpace P, @NormedAddTorsor Vec P _ _

variable {P : Type _} [EuclideanPlane P]

def Vec.mk_pt_pt (A B : P) : Vec := (B -ᵥ A)

scoped notation:80 "VEC" A:max B:max => Vec.mk_pt_pt A B -- to make `- VEC A B` work, binding power > 75

instance : EuclideanPlane (Vec) where
  toMetricSpace := _
  toNormedAddTorsor := @SeminormedAddCommGroup.toNormedAddTorsor _ _

instance : @NormedAddTorsor (Vec) P _ _ := EuclideanPlane.toNormedAddTorsor

instance : AddTorsor (Vec) P := by infer_instance

/- vector $AB +$ point $A =$ point $B$ -/
@[simp]
theorem start_vadd_vec_eq_end (A B : P) : (VEC A B) +ᵥ A = B := vsub_vadd B A

@[simp]
theorem vadd_eq_self_iff_vec_eq_zero {A : P} {v : Vec} : v +ᵥ A = A ↔ v = 0 := by
  rw [eq_comm, eq_vadd_iff_vsub_eq, vsub_self, eq_comm]

@[simp]
theorem vec_same_eq_zero (A : P) : VEC A A = 0 := by
  rw [Vec.mk_pt_pt, vsub_self]

theorem neg_vec (A B : P) : - VEC A B = VEC B A := by
  rw [Vec.mk_pt_pt, Vec.mk_pt_pt, neg_vsub_eq_vsub_rev]

@[simp]
theorem neg_vec_norm_eq (A B : P) : (VEC A B).norm = (VEC B A).norm := by
  rw [← neg_vec A B]
  simp only [neg_Vec_norm_eq_Vec_norm]

theorem eq_iff_vec_eq_zero (A B : P) : B = A ↔ VEC A B = 0 := vsub_eq_zero_iff_eq.symm

theorem ne_iff_vec_ne_zero (A B : P) : B ≠ A ↔ VEC A B ≠ 0 := (eq_iff_vec_eq_zero A B).not

@[simp]
theorem vec_add_vec (A B C : P) : VEC A B + VEC B C = VEC A C := by
  rw [add_comm, Vec.mk_pt_pt, Vec.mk_pt_pt, Vec.mk_pt_pt, vsub_add_vsub_cancel]

@[simp]
theorem vec_of_pt_vadd_pt_eq_vec (A : P) (v : Vec) : (VEC A (v +ᵥ A)) = v := vadd_vsub v A

@[simp]
theorem vec_sub_vec (O A B: P) : VEC O B - VEC O A = VEC A B := by
  rw [Vec.mk_pt_pt, Vec.mk_pt_pt, Vec.mk_pt_pt, vsub_sub_vsub_cancel_right]

@[simp]
theorem vec_sub_vec' (O A B: P) : VEC A O - VEC B O = VEC A B := by
  rw [Vec.mk_pt_pt, Vec.mk_pt_pt, Vec.mk_pt_pt, vsub_sub_vsub_cancel_left]

theorem pt_eq_pt_of_eq_smul_smul {O A B : P} {v : Vec} {tA tB : ℝ} (h : tA = tB) (ha : VEC O A = tA • v) (hb : VEC O B = tB • v) : A = B := by
  have hc : VEC A B = VEC O B - VEC O A := (vec_sub_vec O A B).symm
  rw [ha, hb, ← sub_smul, Iff.mpr sub_eq_zero h.symm, zero_smul] at hc
  exact ((eq_iff_vec_eq_zero A B).2 hc).symm

theorem eq_of_smul_Vec_nd_eq_smul_Vec_nd {v : Vec_nd} {tA tB : ℝ} (e : tA • v.1 = tB • v.1) : tA = tB := by
  have h : (tA - tB) • v.1 = 0 := by
    rw [sub_smul, e, Complex.real_smul, sub_self]
  rw [smul_eq_zero] at h
  rcases h with x | y
  linarith
  have: v.1 ≠ 0 := by
    apply v.2
  contradiction

def Vec_nd.mk_pt_pt (A B : P) (h : B ≠ A) : Vec_nd := ⟨Vec.mk_pt_pt A B, (ne_iff_vec_ne_zero A B).mp h⟩

scoped notation:80 "VEC_nd" A:max B:max h:max => Vec_nd.mk_pt_pt A B h ---- to make `- VEC_nd A B h` work, binding power > 75

end EuclidGeom
