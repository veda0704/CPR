from django.db import models
from django.conf import settings
import json

class ACLSSession(models.Model):
    user = models.ForeignKey(settings.AUTH_USER_MODEL, on_delete=models.CASCADE)
    start_time = models.DateTimeField(auto_now_add=True)
    end_time = models.DateTimeField(null=True, blank=True)
    witnessed = models.BooleanField(null=True, blank=True)  # True if witnessed, False if unwitnessed, None if not set
    actions = models.JSONField(default=list)  # List of actions taken, e.g. [{"step": "responsive", "time": 1234567890, "choice": "NO"}]
    medications = models.JSONField(default=list)  # List of medications administered
    elapsed_time = models.IntegerField(default=0)  # Total elapsed time in seconds

    def __str__(self):
        return f"ACLS Session for {self.user.email} at {self.start_time}"

    def add_action(self, step, choice=None, time=None):
        if time is None:
            import time
            time = int(time.time())
        action = {"step": step, "time": time}
        if choice:
            action["choice"] = choice
        self.actions.append(action)
        self.save()

    def add_medication(self, med, dose, time=None):
        if time is None:
            import time
            time = int(time.time())
        med_entry = {"medication": med, "dose": dose, "time": time}
        self.medications.append(med_entry)
        self.save()
