import Mathlib.Analysis.InnerProductSpace.Basic
import Mathlib.Analysis.SpecialFunctions.Complex.Arg
import Mathlib.Analysis.SpecialFunctions.Trigonometric.Complex
import Mathlib.Analysis.Complex.Arg
import Mathlib.Data.Real.Sign
import Mathlib.Tactic.ProjectionNotation
/-!
# Standard Vector Space

This file defines the standard inner product real vector space of dimension two, but we will build this on the complex numbers.

## Important definitions

* `Vec` : The class of "2-dim vectors" `ℂ`, with a real inner product space structure which is instancialized.
* `Vec_nd` : The class of nonzero vectors, `nd` for nondegenerate.
* `Dir` : The class of vectors of unit length `Vec_nd`.
* `Proj` : the class of `Dir` quotient by `±1`, in other words, `ℝP¹`.

## Notation

## Implementation Notes

Then we define the class `Dir` of vectors of unit length. We equip it with the structure of commutative group. The quotient `Proj` of `Dir` by `±1` is automatically a commutative group.

## Further Works

-/

noncomputable section
namespace EuclidGeom
scoped macro_rules | `($x ^ $y) => `(HPow.hPow $x $y)
scoped notation "π" => Real.pi

/- the notation for the class of vectors -/
abbrev Vec := ℂ

/- the class of non-degenerate vectors -/
def Vec_nd := {z : ℂ // z ≠ 0}

instance : Coe Vec_nd Vec where
  coe := fun z => z.1

namespace Vec_nd

instance : Mul Vec_nd where
  mul z w := ⟨z * w, mul_ne_zero_iff.2 ⟨z.2, w.2⟩⟩

instance : Semigroup Vec_nd where
  mul_assoc := fun _ _ _ => Subtype.ext (mul_assoc _ _ _)

instance : Monoid Vec_nd where
  one := ⟨1, one_ne_zero⟩
  one_mul := fun _ => Subtype.ext (one_mul _)
  mul_one := fun _ => Subtype.ext (mul_one _)

instance : CommGroup Vec_nd where
  inv := fun z => ⟨z⁻¹, inv_ne_zero z.2⟩
  mul_left_inv := fun z => Subtype.ext (inv_mul_cancel z.2)
  mul_comm := fun z w => Subtype.ext (mul_comm z.1 w.1)

instance : HasDistribNeg Vec_nd where
  neg := fun z => ⟨-z, neg_ne_zero.2 z.2⟩
  neg_neg := fun _ => Subtype.ext (neg_neg _)
  neg_mul := fun _ _ => Subtype.ext (neg_mul _ _)
  mul_neg := fun _ _ => Subtype.ext (mul_neg _ _)

end Vec_nd

@[pp_dot]
def Vec.norm (x : Vec) := Complex.abs x

/- norm of multiplication by a nonnegative real number equal multiplication of norm -/
theorem Vec.norm_smul_eq_mul_norm {x : ℝ} (x_nonneg : 0 ≤ x) (u : Vec) : Vec.norm (x • u) = x * Vec.norm u := by
  unfold Vec.norm
  simp only [Complex.real_smul, map_mul, Complex.abs_ofReal, mul_eq_mul_right_iff, abs_eq_self, map_eq_zero]
  tauto

@[simp]
theorem neg_Vec_norm_eq_Vec_norm (z : Vec) : (-z).norm = z.norm := by
  have h : Complex.abs (-z) = Complex.abs (z) := by
    simp only [map_neg_eq_map]
  unfold Vec.norm
  rw [h]

-- norm is nonnegetive
theorem Vec.norm_nonnegative (u : Vec) : 0 ≤ u.norm := Real.sqrt_nonneg _

@[pp_dot]
def Vec_nd.norm (x : Vec_nd) := Vec.norm x

theorem Vec_nd.norm_ne_zero (z : Vec_nd) : z.norm ≠ 0 := norm_ne_zero_iff.2 z.2

theorem Vec_nd.norm_pos (z : Vec_nd) : Vec_nd.norm z > 0 := norm_pos_iff.2 z.2

theorem Vec_nd.ne_zero_of_ne_zero_smul (z : Vec_nd) {t : ℝ} (h : t ≠ 0) : t • z.1 ≠ 0 := by
  simp only [ne_eq, smul_eq_zero, h, z.2, or_self, not_false_eq_true]

@[simp]
theorem fst_of_one_tovec_eq_one : (1 : Vec_nd).1 = 1 := rfl

@[simp]
theorem fst_neg_Vec_nd_is_neg_fst_Vec_nd (z : Vec_nd) : (-z).1 = -(z.1) := rfl

@[simp]
theorem ne_zero_of_Vec_nd (z : Vec_nd) : z.1 ≠ 0 := z.2

@[simp]
theorem real_smul_Vec_eq_mul_of (z : Vec) (r : ℝ) : r • z = r * z := rfl

@[simp]
theorem fst_of_mul_eq_fst_mul_fst (z w : Vec_nd) : (z * w).1 = z.1 * w.1 := by rfl

@[simp]
theorem norm_of_Vec_nd_eq_norm_of_Vec_nd_fst (z : Vec_nd) : Vec_nd.norm z = Vec.norm z := rfl

@[simp]
theorem neg_Vec_nd_norm_eq_Vec_nd_norm (x : Vec_nd) : (-x).norm = x.norm := by
  simp only [ne_eq, fst_neg_Vec_nd_is_neg_fst_Vec_nd, norm_of_Vec_nd_eq_norm_of_Vec_nd_fst, neg_Vec_norm_eq_Vec_norm]

@[ext]
structure Dir where
  toVec : Vec
  unit : @inner ℝ _ _ toVec toVec = 1

@[simp]
theorem dir_tovec_fst_mul_fst_plus_snd_mul_snd_eq_one (x : Dir) : x.1.1 * x.1.1 + x.1.2 * x.1.2 = 1 := by
  rw [← x.2]
  unfold inner InnerProductSpace.toInner InnerProductSpace.complexToReal InnerProductSpace.isROrCToReal
  simp only [Complex.inner, Complex.mul_re, Complex.conj_re, Complex.conj_im, neg_mul, sub_neg_eq_add]

@[pp_dot]
def Vec_nd.toDir (z : Vec_nd) : Dir where
  toVec := (Vec.norm z.1)⁻¹ • z.1
  unit := by
    rw [inner_smul_left _ _, inner_smul_right _ _]
    simp only [map_inv₀, IsROrC.conj_to_real]
    rw [inv_mul_eq_iff_eq_mul₀, inv_mul_eq_iff_eq_mul₀, ← mul_assoc, ← pow_two, real_inner_self_eq_norm_sq, mul_one]
    rfl
    exact norm_ne_zero_iff.2 z.2
    exact norm_ne_zero_iff.2 z.2

--nondegenerate vector equal norm multiply vector toDir
@[simp ↓]
theorem Vec_nd.norm_smul_todir_eq_self (v : Vec_nd) :  v.norm • v.toDir.toVec = v.1 := by
  symm
  apply (inv_smul_eq_iff₀ (Iff.mpr norm_ne_zero_iff v.2)).1
  rfl

@[simp ↓]
theorem Vec_nd.norm_mul_todir_eq_self (v : Vec_nd) :  v.norm * v.toDir.toVec = v.1 := by
  symm
  apply (inv_smul_eq_iff₀ (Iff.mpr norm_ne_zero_iff v.2)).1
  rfl

-- Basic facts about Dir, the group structure, neg, and the fact that we can make angle using Dir. There are a lot of relevant (probably easy) theorems under the following namespace.

namespace Dir

/- the CommGroup instance on `Dir` -/

instance : Neg Dir where
  neg := fun z => {
      toVec := -z.toVec
      unit := by
        rw [← unit]
        exact inner_neg_neg _ _
    }

instance : Mul Dir where
  mul := fun z w => {
    toVec := z.1 * w.1
    unit := by
      nth_rw 1 [← one_mul 1, ← z.unit, ← w.unit]
      unfold Inner.inner InnerProductSpace.toInner InnerProductSpace.complexToReal InnerProductSpace.isROrCToReal
      simp only [Complex.inner, map_mul, Complex.mul_re, Complex.conj_re, Complex.conj_im, mul_neg, neg_mul, neg_neg,
        Complex.mul_im, sub_neg_eq_add]
      ring
  }

instance : One Dir where
  one := {
    toVec := 1
    unit := by
      simp only [Complex.inner, map_one, mul_one, Complex.one_re]
  }

/- Put tautological theorems into simp -/
@[simp]
theorem fst_of_one_eq_one : (1 : Dir).1.1 = 1 := rfl

@[simp]
theorem snd_of_one_eq_zero : (1 : Dir).1.2 = 0 := rfl

@[simp]
theorem one_eq_one_toComplex : (1 : Dir).1 = 1 := rfl

@[simp]
theorem tovec_sq_add_sq_eq_one (x : Dir) : x.1.1 ^ 2 + x.1.2 ^ 2 = 1 := by
  rw [pow_two, pow_two]
  simp only [dir_tovec_fst_mul_fst_plus_snd_mul_snd_eq_one]

-- Give a CommGroup structure to Dir by the mul structure of ℂ

instance : Semigroup Dir where
  mul_assoc _ _ _ := by
    ext : 1
    unfold toVec HMul.hMul instHMul Mul.mul instMulDir
    simp
    ring_nf

instance : Monoid Dir where
  one_mul := fun _ => by
    ext : 1
    unfold toVec HMul.hMul instHMul Mul.mul Semigroup.toMul instSemigroupDir instMulDir
    simp only [Dir.one_eq_one_toComplex, one_mul]
  mul_one := fun _ => by
    ext : 1
    unfold toVec HMul.hMul instHMul Mul.mul Semigroup.toMul instSemigroupDir instMulDir
    simp only [Dir.one_eq_one_toComplex, mul_one]

instance : CommGroup Dir where
  inv := fun x => {
    toVec := ⟨x.1.1, -x.1.2⟩
    unit := by
      unfold inner InnerProductSpace.toInner InnerProductSpace.complexToReal InnerProductSpace.isROrCToReal
      simp only [Complex.inner, Complex.mul_re, Complex.conj_re, Complex.conj_im, neg_neg, mul_neg, sub_neg_eq_add,
        dir_tovec_fst_mul_fst_plus_snd_mul_snd_eq_one]
  }
  mul_left_inv x := by
    ext : 1
    unfold Inv.inv HMul.hMul instHMul Mul.mul Semigroup.toMul Monoid.toSemigroup instMonoidDir instSemigroupDir instMulDir HMul.hMul instHMul Mul.mul Complex.instMulComplex
    ext
    simp only [neg_mul, sub_neg_eq_add, dir_tovec_fst_mul_fst_plus_snd_mul_snd_eq_one, one_eq_one_toComplex,
      Complex.one_re]
    simp only [neg_mul, sub_neg_eq_add, dir_tovec_fst_mul_fst_plus_snd_mul_snd_eq_one, one_eq_one_toComplex,
      Complex.one_im]
    ring
  mul_comm _ _ := by
    ext : 1
    unfold toVec HMul.hMul instHMul Mul.mul Semigroup.toMul Monoid.toSemigroup instMonoidDir instSemigroupDir instMulDir
    dsimp
    ring_nf

instance : HasDistribNeg Dir where
  neg := Neg.neg
  neg_neg _ := by
    unfold Neg.neg instNegDir
    simp only [neg_neg]
  neg_mul _ _ := by
    ext : 1
    unfold Neg.neg instNegDir toVec HMul.hMul instHMul Mul.mul instMulDir toVec
    simp only [neg_mul]
  mul_neg _ _ := by
    ext : 1
    unfold Neg.neg instNegDir toVec HMul.hMul instHMul Mul.mul instMulDir toVec
    simp only [mul_neg]

@[simp]
theorem tovec_neg_eq_neg_tovec (x : Dir) : (-x).toVec = -(x.toVec) := rfl

@[simp]
theorem fst_of_neg_one_eq_neg_one : (-1 : Dir).toVec.1 = -1 := rfl

@[simp]
theorem snd_of_neg_one_eq_zero : (-1 : Dir).toVec.2 = 0 := by
  rw [← neg_zero]
  rfl

theorem tovec_ne_zero (x : Dir) : x.toVec ≠ 0 := by
  by_contra h
  have h' : @inner ℝ _ _ x.toVec x.toVec = 0 := by
    rw [h]
    unfold inner InnerProductSpace.toInner InnerProductSpace.complexToReal InnerProductSpace.isROrCToReal
    simp only [inner_zero_right]
  let g := x.unit
  rw [h'] at g
  exact zero_ne_one g

def toVec_nd (x : Dir) : Vec_nd := ⟨x.toVec, tovec_ne_zero x⟩

@[simp]
theorem norm_of_dir_tovec_eq_one (x : Dir) : Vec.norm x.toVec = 1 := by
  unfold Vec.norm Complex.abs Complex.normSq
  simp only [MonoidWithZeroHom.coe_mk, ZeroHom.coe_mk, AbsoluteValue.coe_mk, MulHom.coe_mk, dir_tovec_fst_mul_fst_plus_snd_mul_snd_eq_one, Real.sqrt_one]

@[simp]
theorem dir_tovec_nd_todir_eq_self (x : Dir) : Vec_nd.toDir (⟨x.toVec, tovec_ne_zero x⟩ : Vec_nd) = x := by
  ext : 1
  unfold Vec_nd.toDir
  simp only [norm_of_dir_tovec_eq_one, inv_one, one_smul]

theorem tovec_nd_todir_eq_self (x : Dir) : x.toVec_nd.toDir = x := x.dir_tovec_nd_todir_eq_self

/- The direction `Dir.I`, defined as `Complex.I`, the direction of y-axis. It will be used in section perpendicular. -/
def I : Dir where
  toVec := Complex.I
  unit := by
    unfold inner InnerProductSpace.toInner InnerProductSpace.complexToReal InnerProductSpace.isROrCToReal
    simp only [Complex.inner, Complex.conj_I, neg_mul, Complex.I_mul_I, neg_neg, Complex.one_re]

@[simp]
theorem fst_of_I_eq_zero : I.1.1 = 0 := rfl

@[simp]
theorem snd_of_I_eq_one : I.1.2 = 1 := rfl

@[simp]
theorem I_toComplex_eq_I : I.1 = Complex.I := rfl

@[simp]
theorem neg_I_toComplex_eq_neg_I : (-I).1 = -Complex.I := rfl

@[simp]
theorem I_mul_I_eq_neg_one : I * I = -(1 : Dir) := by
  ext : 1
  unfold HMul.hMul instHMul Mul.mul instMulDir
  simp only [I_toComplex_eq_I, Complex.I_mul_I, tovec_neg_eq_neg_tovec]
  ext
  rfl
  rfl

@[simp]
theorem inv_of_I_eq_neg_I : I⁻¹ = - I := by
  apply @mul_right_cancel _ _ _ _ I _
  simp only [mul_left_inv, neg_mul, I_mul_I_eq_neg_one, neg_neg]

instance : SMul Dir Vec where
  smul := fun d v => d.1 * v

instance : DistribMulAction Dir Vec where
  one_smul := one_mul
  mul_smul _ _ := mul_assoc _ _
  smul_zero _ := mul_zero _
  smul_add _ := mul_add _

instance : SMul Dir Vec_nd where
  smul := fun d v => d.toVec_nd * v

instance : MulAction Dir Vec_nd where
  one_smul := one_mul
  mul_smul x y := mul_assoc x.toVec_nd y.toVec_nd

end Dir

def PM : Dir → Dir → Prop :=
fun x y => x = y ∨ x = -y

-- Now define the equivalence PM.

namespace PM

def equivalence : Equivalence PM where
  refl _ := by simp [PM]
  symm := fun h =>
    match h with
      | Or.inl h₁ => Or.inl (Eq.symm h₁)
      | Or.inr h₂ => Or.inr (Iff.mp neg_eq_iff_eq_neg (id (Eq.symm h₂)))
  trans := by
    intro _ _ _ g h
    unfold PM
    match g with
      | Or.inl g₁ =>
          rw [← g₁] at h
          exact h
      | Or.inr g₂ =>
          match h with
            | Or.inl h₁ =>
              right
              rw [← h₁, g₂]
            | Or.inr h₂ =>
              left
              rw [g₂, h₂, ← Iff.mp neg_eq_iff_eq_neg rfl]

instance con : Con Dir where
  r := PM
  iseqv := PM.equivalence
  mul' := by
    unfold Setoid.r PM
    intro _ x _ z g h
    match g with
      | Or.inl g₁ =>
        match h with
          | Or.inl h₁ =>
            left
            rw [g₁, h₁]
          | Or.inr h₂ =>
            right
            rw [g₁, h₂, ← mul_neg _ _]
      | Or.inr g₂ =>
        match h with
          | Or.inl h₁ =>
            right
            rw [g₂, h₁, ← neg_mul _ _]
          | Or.inr h₂ =>
            left
            rw [g₂, h₂, ← neg_mul_neg x z]

end PM

def Proj := Con.Quotient PM.con

-- We can take quotient from Dir to get Proj.

namespace Proj

instance : MulOneClass Proj := Con.mulOneClass PM.con

instance : Group Proj := Con.group PM.con

instance : CommMonoid Proj := Con.commMonoid PM.con

instance : CommGroup Proj where
  mul_comm := instCommMonoidProj.mul_comm

end Proj

def Dir.toProj (v : Dir) : Proj := ⟦v⟧

instance : Coe Dir Proj where
  coe v := v.toProj

theorem Dir.eq_toproj_iff (x y : Dir) : x.toProj = y.toProj ↔ x = y ∨ x = -y := Quotient.eq (r := PM.con.toSetoid)

theorem Dir.eq_toproj_iff' {x y : Dir} : x.toProj = y.toProj ↔ PM x y := by rw [Dir.eq_toproj_iff, PM]

theorem Dir.neg_toproj_eq {x : Dir} : (- x).toProj = x.toProj := (Dir.eq_toproj_iff (-x) x).mpr (.inr rfl)

def Vec_nd.toProj (v : Vec_nd) : Proj := (Vec_nd.toDir v : Proj)

theorem dir_toVec_nd_toProj_eq_dir_toProj (u : Dir) : u.toVec_nd.toProj = u.toProj := by
  nth_rw 2 [← Dir.tovec_nd_todir_eq_self u]
  rfl

-- Coincidence of toProj gives rise to important results, especially that two Vec_nd-s have the same toProj iff they are equal by taking a real (nonzero) scaler. We will prove this statement in the following section.

section Vec_nd_toproj

theorem todir_eq_todir_smul_pos (u v : Vec_nd) {t : ℝ} (h : v.1 = t • u.1) (ht : 0 < t) : Vec_nd.toDir u = Vec_nd.toDir v := by
  unfold Vec_nd.toDir
  ext : 1
  have g : (Vec.norm v) • u.1 = (Vec.norm u) • v.1 := by
    have w₁ : (Vec.norm (t • u.1)) = ‖t‖ * (Vec.norm u.1) := norm_smul t u.1
    have w₂ : ‖t‖ = t := abs_of_pos ht
    rw [h, w₁, w₂, mul_comm]
    exact mul_smul (Vec.norm u.1) t u.1
  have g' : Vec.norm v * u.1 = Vec.norm u * v.1 := g
  have hu : (Vec.norm u : ℂ) ≠ 0 := by
    rw [← norm_of_Vec_nd_eq_norm_of_Vec_nd_fst u]
    exact Iff.mpr Complex.ofReal_ne_zero (Vec_nd.norm_ne_zero u)
  have hv : (Vec.norm v : ℂ) ≠ 0 := by
    rw [← norm_of_Vec_nd_eq_norm_of_Vec_nd_fst v]
    exact Iff.mpr Complex.ofReal_ne_zero (Vec_nd.norm_ne_zero v)
  let w := (inv_mul_eq_iff_eq_mul₀ hu).2 g'
  rw [mul_left_comm] at w
  simp only [ne_eq, norm_of_Vec_nd_eq_norm_of_Vec_nd_fst, Complex.real_smul, Complex.ofReal_inv, MonoidHom.coe_mk,
    OneHom.coe_mk]
  exact Eq.symm ((inv_mul_eq_iff_eq_mul₀ hv).2 (Eq.symm w))

theorem neg_todir_eq_todir_smul_neg (u v : Vec_nd) {t : ℝ} (h : v.1 = t • u.1) (ht : t < 0) : -Vec_nd.toDir u = Vec_nd.toDir v := by
  unfold Vec_nd.toDir
  ext : 1
  simp only [ne_eq, MonoidHom.coe_mk, OneHom.coe_mk, fst_neg_Vec_nd_is_neg_fst_Vec_nd]
  have g : (-Vec.norm v) • u.1 = (Vec.norm u) • v.1 := by
    have w₁ : (Vec.norm (t • u.1)) = ‖t‖ * (Vec.norm u.1) := norm_smul t u.1
    have w₂ : ‖t‖ = -t := abs_of_neg ht
    rw [h, w₁, w₂, neg_mul, neg_neg, mul_comm]
    exact mul_smul (Vec.norm u.1) t u.1
  have g' : (-(Vec.norm v : ℂ)) * u.1 = Vec.norm u * v.1 := by
    rw [Eq.symm (Complex.ofReal_neg (Vec.norm v))]
    exact g
  have hu : (Vec.norm u : ℂ) ≠ 0 := by
    rw [← norm_of_Vec_nd_eq_norm_of_Vec_nd_fst u]
    exact Iff.mpr Complex.ofReal_ne_zero (Vec_nd.norm_ne_zero u)
  have hv : -(Vec.norm v : ℂ) ≠ 0 := by
    rw [← norm_of_Vec_nd_eq_norm_of_Vec_nd_fst v]
    exact neg_ne_zero.2 (Iff.mpr Complex.ofReal_ne_zero (Vec_nd.norm_ne_zero v))
  let w := (inv_mul_eq_iff_eq_mul₀ hu).2 g'
  rw [mul_left_comm] at w
  simp only [ne_eq, norm_of_Vec_nd_eq_norm_of_Vec_nd_fst, Complex.real_smul, Complex.ofReal_inv, MonoidHom.coe_mk,
    OneHom.coe_mk]
  let w' := Eq.symm ((inv_mul_eq_iff_eq_mul₀ hv).2 (Eq.symm w))
  rw [← neg_inv, neg_mul] at w'
  exact Iff.mpr neg_eq_iff_eq_neg w'

@[simp]
theorem neg_todir_eq_todir_eq (z : Vec_nd) : Vec_nd.toDir (-z) = - Vec_nd.toDir z := by
  symm
  apply neg_todir_eq_todir_smul_neg z (-z) (t := -1)
  simp only [ne_eq, fst_neg_Vec_nd_is_neg_fst_Vec_nd, neg_smul, one_smul]
  linarith

theorem eq_toproj_of_smul (u v : Vec_nd) {t : ℝ} (h : v.1 = t • u.1) : Vec_nd.toProj u = Vec_nd.toProj v := by
  have ht : t ≠ 0 := by
    by_contra ht'
    rw [ht', zero_smul ℝ u.1] at h
    exact v.2 h
  have ht₁ : (0 < t) ∨ (t < 0) := Ne.lt_or_lt (Ne.symm ht)
  unfold Vec_nd.toProj Dir.toProj
  apply Quotient.sound
  unfold HasEquiv.Equiv instHasEquiv PM.con PM
  simp only [Con.rel_eq_coe, Con.rel_mk]
  match ht₁ with
    | Or.inl ht₂ =>
      left
      exact todir_eq_todir_smul_pos u v h ht₂
    | Or.inr ht₃ =>
      right
      exact Iff.mp neg_eq_iff_eq_neg (neg_todir_eq_todir_smul_neg u v h ht₃)

theorem smul_of_eq_toproj (u v : Vec_nd) (h : Vec_nd.toProj u = Vec_nd.toProj v) : ∃ (t : ℝ), v.1 = t • u.1 := by
  let h' := Quotient.exact h
  unfold HasEquiv.Equiv instHasEquiv PM.con PM at h'
  simp only [Con.rel_eq_coe, Con.rel_mk] at h'
  match h' with
    | Or.inl h₁ =>
      rw [Dir.ext_iff] at h₁
      use (Vec.norm v.1) * (Vec.norm u.1)⁻¹
      have w₁ : (Vec.norm v.1)⁻¹ • v.1 = (Vec.norm u.1)⁻¹ • u.1 ↔ v.1 = (Vec.norm v.1) • (Vec.norm u.1)⁻¹ • u.1 := inv_smul_eq_iff₀ (Iff.mpr norm_ne_zero_iff v.2)
      rw [mul_smul]
      exact (w₁.mp (Eq.symm h₁))
    | Or.inr h₂ =>
      rw [Dir.ext_iff] at h₂
      use (-Vec.norm v.1) * (Vec.norm u.1)⁻¹
      have w₂ : (-Vec.norm v.1)⁻¹ • v.1 = (Vec.norm u.1)⁻¹ • u.1 ↔ v.1 = (-Vec.norm v.1) • (Vec.norm u.1)⁻¹ • u.1 := inv_smul_eq_iff₀ (Iff.mpr neg_ne_zero (Iff.mpr norm_ne_zero_iff v.2))
      rw [mul_smul]
      refine (w₂.mp (Eq.symm ?_))
      rw [← neg_inv, neg_smul]
      exact h₂

-- The main theorem of Vec_nd.toProj
theorem Vec_nd.eq_toproj_iff (u v : Vec_nd) : (Vec_nd.toProj u = Vec_nd.toProj v) ↔ ∃ (t : ℝ), v.1 = t • u.1 := by
  constructor
  · intro h
    exact smul_of_eq_toproj _ _ h
  · intro h'
    rcases h' with ⟨t, h⟩
    exact eq_toproj_of_smul _ _ h

end Vec_nd_toproj

section Perpendicular

namespace Proj

def I : Proj := Dir.I

theorem one_ne_I : ¬1=(Proj.I) := by
  intro h
  have h0: Dir.I=1∨Dir.I=-1 := by
    apply (Con.eq PM.con).mp
    exact id (Eq.symm h)
  have h1: (Dir.I)^2=1 := by
    rcases h0 with h2|h2
    rw [h2]
    exact one_pow 2
    rw [h2]
    exact neg_one_sq
  have h3: (Dir.I)^2=-1 :=by
    rw [←Dir.I_mul_I_eq_neg_one]
    exact sq Dir.I
  have h4: ¬(-1:Dir)=(1:Dir) := by
   intro k
   rw [Dir.ext_iff, Complex.ext_iff] at k
   simp at k
   linarith
  rw [h3] at h1
  exact h4 h1

@[simp]
theorem neg_one_eq_one_of_Proj : ((-1 : Dir) : Proj) = (1 : Proj) := by
  unfold Dir.toProj
  apply Quotient.sound
  unfold HasEquiv.Equiv instHasEquiv PM.con PM
  simp only [Con.rel_eq_coe, Con.rel_mk, or_true]

@[simp]
theorem I_mul_I_eq_one_of_Proj : I * I = 1 := by
  have h : Dir.toProj (Dir.I * Dir.I) = (Dir.toProj Dir.I) * (Dir.toProj Dir.I):= rfl
  have h' : Dir.toProj Dir.I = (I : Proj) := rfl
  rw [← neg_one_eq_one_of_Proj, ← Dir.I_mul_I_eq_neg_one, h, h']

def perp : Proj → Proj := fun x => I * x

@[simp]
theorem perp_perp_eq_self (x : Proj) : x.perp.perp = x := by
  unfold perp
  rw [← mul_assoc]
  simp only [I_mul_I_eq_one_of_Proj, one_mul]

end Proj

end Perpendicular

-- Our aim is to prove nonparallel lines have common point, but in this section, we will only form the theorem in a Linear algebraic way by proving two Vec_nd-s could span the space with different toProj, which is the main theorem about toProj we will use in the proof of the intersection theorem.

section Linear_Algebra

def det (u v : Vec) : ℝ := u.1 * v.2 - u.2 * v.1

theorem det_symm (u v : Vec) : det u v = - det v u := by simp only [det, mul_comm, neg_sub]

def det' (u v : Vec) : ℂ := u.1 * v.2 - u.2 * v.1

def cu (u v w: Vec) : ℝ := (det u v)⁻¹ * (w.1 * v.2 - v.1 * w.2)

def cv (u v w: Vec) : ℝ := (det u v)⁻¹ * (u.1 * w.2 - w.1 * u.2)

theorem cu_cv (u v w : Vec) : cu u v w = cv v u w := by
  rw [cu, cv, det_symm v u, inv_neg]
  field_simp

theorem cu_neg (u v w : Vec) : cu u v (- w) = - cu u v w := by
  rw [cu, cu, neg_mul_eq_mul_neg]
  congr
  rw [Complex.neg_re, Complex.neg_im, neg_mul, mul_neg, sub_neg_eq_add, neg_sub, neg_add_eq_sub]

theorem det_eq_zero_iff_eq_smul (u v : Vec) (hu : u ≠ 0) : det u v = 0 ↔ (∃ (t : ℝ), v = t • u) := by
  unfold det
  have h : (u.1 ≠ 0) ∨ (u.2 ≠ 0) := by
    by_contra _
    have h₁ : u.1 = 0 := by tauto
    have h₂ : u.2 = 0 := by tauto
    have hu' : u = ⟨0, 0⟩ := by exact Complex.ext h₁ h₂
    tauto
  constructor
  · intro e
    match h with
    | Or.inl h₁ =>
      use v.1 * (u.1⁻¹)
      unfold HSMul.hSMul instHSMul SMul.smul Complex.instSMulRealComplex
      simp only [smul_eq_mul, zero_mul, sub_zero, add_zero, ne_eq]
      ext
      simp only [smul_eq_mul, ne_eq]
      exact Iff.mp (div_eq_iff h₁) rfl
      simp only [smul_eq_mul]
      rw [mul_comm v.1 u.1⁻¹, mul_assoc, mul_comm v.1 u.2]
      rw [sub_eq_zero] at e
      exact Iff.mpr (eq_inv_mul_iff_mul_eq₀ h₁) e
    | Or.inr h₂ =>
      use v.2 * (u.2⁻¹)
      unfold HSMul.hSMul instHSMul SMul.smul Complex.instSMulRealComplex
      simp only [smul_eq_mul, zero_mul, sub_zero, add_zero, ne_eq]
      ext
      simp only [smul_eq_mul]
      rw [mul_comm v.2 u.2⁻¹, mul_assoc]
      rw [sub_eq_zero, mul_comm u.1 v.2] at e
      exact Iff.mpr (eq_inv_mul_iff_mul_eq₀ h₂) (id (Eq.symm e))
      simp only [smul_eq_mul, ne_eq]
      exact Iff.mp (div_eq_iff h₂) rfl
  · intro e'
    rcases e' with ⟨t, e⟩
    unfold HSMul.hSMul instHSMul SMul.smul Complex.instSMulRealComplex at e
    simp only [smul_eq_mul] at e
    rcases e
    ring

-- det theorems for Vec_nd
theorem det_eq_zero_of_toProj_eq (u v : Vec_nd) (toprojeq : u.toProj = v.toProj) : det u v = 0 := ((det_eq_zero_iff_eq_smul u.1 v.1 u.2).2) (smul_of_eq_toproj u v toprojeq)

theorem toProj_eq_of_det_eq_zero (u v : Vec_nd) (det_eq_zero : det u v = 0) : u.toProj = v.toProj := (Vec_nd.eq_toproj_iff u v).mpr ((det_eq_zero_iff_eq_smul u.1 v.1 u.2).1 det_eq_zero)

theorem det_eq_zero_iff_toProj_eq (u v : Vec_nd) : det u v = 0 ↔ u.toProj = v.toProj := ⟨fun z => ((Vec_nd.eq_toproj_iff u v).mpr ((det_eq_zero_iff_eq_smul u.1 v.1 u.2).1 z)), fun z => (((det_eq_zero_iff_eq_smul u.1 v.1 u.2).2) (smul_of_eq_toproj u v z))⟩

theorem det'_ne_zero_of_not_colinear {u v : Vec} (hu : u ≠ 0) (h' : ¬(∃ (t : ℝ), v = t • u)) : det' u v ≠ 0 := by
  unfold det'
  have h₁ : (¬ (∃ (t : ℝ), v = t • u)) → (¬ (u.1 * v.2 - u.2 * v.1 = 0)) := by
    intro _
    by_contra h₂
    let _ := (det_eq_zero_iff_eq_smul u v hu).1 h₂
    tauto
  symm
  field_simp
  have trivial : ((u.re : ℂ)  * v.im - u.im * v.re) = ((Sub.sub (α := ℝ) (Mul.mul (α := ℝ) u.re v.im)  (Mul.mul (α := ℝ) u.im v.re)) : ℂ) := by
    symm
    calc
      ((Sub.sub (α := ℝ) (Mul.mul (α := ℝ) u.re v.im)  (Mul.mul (α := ℝ) u.im v.re)) : ℂ) = ((Mul.mul u.re v.im) - (Mul.mul u.im v.re)) := Complex.ofReal_sub _ _
      _ = ((Mul.mul u.re v.im) - (u.im * v.re)) := by
        rw [← Complex.ofReal_mul u.im v.re]
        rfl
      _ = ((u.re * v.im) - (u.im * v.re)) := by
        rw [← Complex.ofReal_mul u.re _]
        rfl
  rw [trivial, ← ne_eq]
  symm
  rw [ne_eq, Complex.ofReal_eq_zero]
  exact h₁ h'

theorem linear_combination_of_not_colinear' {u v w : Vec} (hu : u ≠ 0) (h' : ¬(∃ (t : ℝ), v = t • u)) : w = (cu u v w) • u + (cv u v w) • v := by
  unfold cu cv det
  have : ((u.re : ℂ)  * v.im - u.im * v.re) ≠ 0 := det'_ne_zero_of_not_colinear hu h'
  field_simp
  apply Complex.ext
  simp
  ring
  simp
  ring

theorem linear_combination_of_not_colinear_vec_nd {u v : Vec_nd} (w : Vec) (h' : Vec_nd.toProj u ≠ Vec_nd.toProj v) : w = (cu u.1 v.1 w) • u.1 + (cv u.1 v.1 w) • v.1 := by
  have h₁ : (Vec_nd.toProj u ≠ Vec_nd.toProj v) → ¬(∃ (t : ℝ), v.1 = t • u.1) := by
    intro _
    by_contra h₂
    let _ := (Vec_nd.eq_toproj_iff u v).2 h₂
    tauto
  exact @linear_combination_of_not_colinear' u.1 v.1 w u.2 (h₁ h')

theorem linear_combination_of_not_colinear_dir {u v : Dir} (w : Vec) (h' : u.toProj ≠ v.toProj) : w = (cu u.1 v.1 w) • u.1 + (cv u.1 v.1 w) • v.1 := by
  have h₁ : (u.toProj ≠ v.toProj) → ¬(∃ (t : ℝ), v.1 = t • u.1) := by
    by_contra h
    push_neg at h
    let u' := u.toVec_nd
    let v' := v.toVec_nd
    have hu0 : (⟨u.toVec, Dir.tovec_ne_zero u⟩ : Vec_nd) = u' := rfl
    have hu1 : u = u'.toDir := by rw [←Dir.dir_tovec_nd_todir_eq_self u, hu0]
    have hu2 : Vec_nd.toProj u' = u.toProj := by
      unfold Vec_nd.toProj
      rw [hu1]
    have hu3 : u.1 = u'.1 := rfl
    have hv0 : (⟨v.toVec, Dir.tovec_ne_zero v⟩ : Vec_nd) = v' := rfl
    have hv1 : v = v'.toDir := by rw [←Dir.dir_tovec_nd_todir_eq_self v, hv0]
    have hv2 : Vec_nd.toProj v' = v.toProj := by
      unfold Vec_nd.toProj
      rw [hv1]
    have hv3 : v.1 = v'.1 := rfl
    rw [hu3, hv3 ,←hu2, ←hv2, ←Vec_nd.eq_toproj_iff u' v'] at h
    tauto
  exact @linear_combination_of_not_colinear' u.1 v.1 w u.toVec_nd.2 (h₁ h')

--bilinearity of det
theorem det_add_left_eq_add_det (u1 u2 v : Vec) : det (u1+u2) v = det u1 v + det u2 v := by
  unfold det
  rw [Complex.add_re, Complex.add_im]
  ring

theorem det_add_right_eq_add_det (u v1 v2 : Vec) : det u (v1+v2) = det u v1 + det u v2 := by
  unfold det
  rw [Complex.add_re, Complex.add_im]
  ring

theorem det_smul_left_eq_mul_det (u v : Vec) (x : ℝ) : det (x • u) v = x * (det u v) := by
  unfold det
  rw[Complex.real_smul, Complex.ofReal_mul_re, Complex.ofReal_mul_im]
  ring

theorem det_smul_right_eq_mul_det (u v : Vec) (x : ℝ) : det u (x • v) = x * (det u v) := by
  unfold det
  rw[Complex.real_smul, Complex.ofReal_mul_re, Complex.ofReal_mul_im]
  ring

--antisymmetricity of det
theorem det_eq_neg_det (u v : Vec) : det u v = -det v u := by
  unfold det
  ring

--permuting vertices of a triangle has simple effect on area
theorem det_sub_eq_det (u v : Vec) : det (u-v) v= det u v := by
  rw [sub_eq_add_neg, det_add_left_eq_add_det u (-v) v]
  have : det (-v) v = 0 := by
    unfold det
    rw [Complex.neg_im, Complex.neg_re]
    ring
  rw [this, add_zero]

--computing area using sine
theorem det_eq_im_of_quotient (u v : Dir) : det u.1 v.1 = (v * (u⁻¹)).1.im := by
  have h1 : u⁻¹.1.im = - u.1.im := rfl
  have h2 : u⁻¹.1.re = u.1.re := rfl
  have h3 : (v * (u⁻¹)).1 = v.1 * u⁻¹.1 := rfl
  rw [h3, Complex.mul_im]
  unfold det
  rw [h1, h2]
  ring

end Linear_Algebra

end EuclidGeom
