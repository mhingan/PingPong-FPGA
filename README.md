![diagrama_tranzitii](https://github.com/user-attachments/assets/3397185d-ddf9-4f7e-a9e3-d6dce538afbf)

# 🕹️ Ping Pong Digital Game – VHDL Project

Acest proiect simulează un joc simplu de ping-pong folosind LED-uri și un afișaj cu 7 segmente. Doi jucători pot interacționa prin butoane, iar scorul este afișat în timp real.

---

## 📂 Structura proiectului

Proiectul este format din 3 fișiere VHDL:

---

### 1. `deBounce.vhd`  
**Rol:** Elimină zgomotul (bouncing-ul) generat de butoane.

#### 🧠 Funcționalitate:
- Primește:
  - `clk`: semnalul de ceas
  - `rst`: reset sincron
  - `button_in`: semnal brut de la un buton
- Procesează semnalul:
  - Numără un număr de cicluri (configurat prin `COUNT_MAX`)
  - Dacă butonul rămâne apăsat stabil, emite un impuls (`pulse_out`)
- Ieșire:
  - `pulse_out`: puls de 1 clk, generat doar la o apăsare validă

#### 🔧 Utilizare:
- Se instanțiază de 2 ori în `pingpong.vhd`, câte una pentru fiecare buton al jucătorilor.

---

### 2. `driver7seg.vhd`  
**Rol:** Controlează afișajul cu 7 segmente (4 cifre).

#### 🧠 Funcționalitate:
- Primește:
  - `clk`: semnal de ceas principal
  - `Din`: date de afișat (16 biți, 4 cifre BCD)
  - `dp_in`: puncte zecimale (câte unul pentru fiecare cifră)
  - `rst`: reset
- Intern:
  - Generează un semnal de 1 kHz printr-un contor (`state`)
  - Comută între cele 4 cifre (multiplexare)
  - Alege din `Din` cifra potrivită, în funcție de adresa generată (`addr`)
  - Codifică cifra selectată în segmente (`seg`)
- Ieșiri:
  - `seg`: semnale pentru segmentele a–g
  - `an`: selectează cifra activă (active low)
  - `dp_out`: punctul zecimal pentru cifra curentă

#### 🔧 Utilizare:
- Este instanțiat în `pingpong.vhd` pentru a afișa scorurile.

---

### 3. `pingpong.vhd`  
**Rol:** Modulul principal al jocului.

#### 🧠 Funcționalitate:
- Primește:
  - `clk`: semnalul de ceas principal
  - `rst`: reset global
  - `b1`, `b2`: butoane pentru jucătorii 1 și 2
- Instanțiază:
  - 2 module `deBounce` pentru filtrarea apăsărilor de la `b1` și `b2`
  - 1 modul `driver7seg` pentru afișarea scorului
- Controlează jocul:
  - Mingea (LED aprins) se deplasează de la stânga la dreapta și invers
  - Jucătorul trebuie să apese butonul când mingea ajunge la marginea sa
  - Dacă nu apasă la timp, celălalt jucător primește punct
- Scor:
  - `scor_ut11`: scorul jucătorului 1 (b1)
  - `scor_ut12`: scorul jucătorului 2 (b2)
  - Afișate în format BCD pe 7 segmente
- Ieșiri:
  - `led`: LED-uri (16), indică poziția mingii
  - `an`, `seg`, `dp`: pentru controlul afișajului cu 7 segmente

#### 💡 Detalii afișaj:
- Scorul este afișat astfel (din stânga spre dreapta):
  - Cifra 3 și 2 → scor jucător 1
  - Cifra 1 și 0 → scor jucător 2
