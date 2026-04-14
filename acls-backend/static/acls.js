let step = "START";

// YES mandatory steps
const positiveRequiredSteps = ["WITNESSED", "RESPONSE"];

function redirectToDashboard() {
  window.location.href = "/dashboard";
}

/* UI */
const title = document.getElementById("title");
const desc = document.getElementById("desc");

const startBtn = document.getElementById("startBtn");
const yesBtn = document.getElementById("yesBtn");
const noBtn = document.getElementById("noBtn");
const okBtn = document.getElementById("okBtn");

/* VISIBILITY */
function hideAll() {
  [startBtn, yesBtn, noBtn, okBtn].forEach(btn => {
    if (btn) btn.style.display = "none";
  });
}


function showStart() {
  hideAll();
  if (startBtn) startBtn.style.display = "block";
}

function showYesNo() {
  hideAll();
  if (yesBtn) yesBtn.style.display = "block";
  if (noBtn) noBtn.style.display = "block";
}

function showOk() {
  hideAll();
  if (okBtn) okBtn.style.display = "block";
}

function setStep(t, d) {
  if (title) title.innerText = t;
  if (desc) desc.innerText = d;
}

/* START */
function startACLS() {
  // Open the server-guided checklist which handles session creation
  window.location.href = "/acls/guided_checklist/";
}

/* BUTTONS */
function yes() { handleDecision(true); }
function no()  { handleDecision(false); }
function ok()  { handleOk(); }

/* DECISION LOGIC */
function handleDecision(ans) {

  if (!ans && positiveRequiredSteps.includes(step)) {
    redirectToDashboard();
    return;
  }

  switch (step) {

    case "WITNESSED":
      step = "RESPONSIVE";
      setStep("Check Responsiveness", "Is the patient responsive?");
      showYesNo();
      break;

    case "RESPONSIVE":
      if (ans) {
        step = "END";
        setStep("Responsive", "Monitor patient");
        showOk();
      } else {
        step = "CALL911";
        setStep("Call for Help", "Call 911");
        showOk();
      }
      break;

    case "BREATHING":
      if (ans) {
        step = "RECOVERY";
        setStep("Breathing", "Place patient in recovery position");
        showOk();
      } else {
        step = "PROTECTION";
        setStep("Airway Protection?", "Is airway protection available?");
        showYesNo();
      }
      break;

    case "PROTECTION":
      if (ans) {
        step = "PULSE";
        setStep("Airway Protected", "Check pulse");
        showOk();
      } else {
        step = "BREATHS";
        setStep("No Protection", "Give 2 rescue breaths");
        showOk();
      }
      break;

    case "RESPONSE":
      step = "PULSE";
      setStep("Check Pulse", "Check pulse");
      showOk();
      break;
  }
}

/* OK STEPS */
function handleOk() {

  switch (step) {

    case "CALL911":
      step = "AIRWAY";
      setStep("Open Airway", "Open airway");
      showOk();
      break;

    case "AIRWAY":
      step = "BREATHING";
      setStep("Check Breathing", "Is patient breathing?");
      showYesNo();
      break;

    case "RECOVERY":
      step = "PULSE";
      setStep("Check Pulse", "Check pulse");
      showOk();
      break;

    case "BREATHS":
      step = "RESPONSE";
      setStep("See Response?", "Do you see any response?");
      showYesNo();
      break;

    case "PULSE":
      step = "END";
      setStep("Pulse Checked", "Proceed with ACLS algorithm");
      showOk();
      break;

    case "END":
      setStep("Start ACLS Completed", "Returning to dashboard");
      setTimeout(redirectToDashboard, 1500);
      break;
  }
}

showStart();
