from django.db import models
from django.conf import settings
from django.core.exceptions import ValidationError

SESSION_STATUS_CHOICES = [
    ('active', 'Active'),
    ('completed', 'Completed'),
    ('aborted', 'Aborted'),
    ('paused', 'Paused'),
]

class ACLSSession(models.Model):
    user = models.ForeignKey(settings.AUTH_USER_MODEL, on_delete=models.CASCADE)
    start_time = models.DateTimeField(auto_now_add=True, db_index=True)
    end_time = models.DateTimeField(null=True, blank=True, db_index=True)
    witnessed = models.BooleanField(null=True, blank=True)  # True if witnessed, False if unwitnessed, None if not set
    status = models.CharField(max_length=32, choices=SESSION_STATUS_CHOICES, default='active', db_index=True)
    deleted_at = models.DateTimeField(null=True, blank=True)
    actions = models.JSONField(default=list)  # List of actions taken, e.g. [{"step": "responsive", "time": 1234567890, "choice": "NO"}]
    elapsed_time = models.IntegerField(default=0)  # Total elapsed time in seconds

    class Meta:
        ordering = ['-start_time']
        indexes = [
            models.Index(fields=['user', 'start_time']),
            models.Index(fields=['user', 'end_time']),
            models.Index(fields=['user', 'status']),
            models.Index(fields=['status', 'start_time']),
            models.Index(fields=['status']),
        ]

    def __str__(self):
        return f"ACLS Session for {self.user.email} at {self.start_time}"

    def clean(self):
        super().clean()
        if not isinstance(self.actions, list):
            raise ValidationError({'actions': 'Actions must be a list.'})

        for action in self.actions:
            if not isinstance(action, dict):
                raise ValidationError({'actions': 'Each action must be an object.'})
            if 'step' not in action or 'time' not in action:
                raise ValidationError({'actions': 'Each action must include step and time fields.'})
            if not isinstance(action['step'], str):
                raise ValidationError({'actions': 'Action step must be a string.'})
            if not isinstance(action['time'], int):
                raise ValidationError({'actions': 'Action time must be an integer timestamp.'})

    def save(self, *args, **kwargs):
        self.full_clean()
        super().save(*args, **kwargs)

    def add_action(self, step, choice=None, time=None):
        if time is None:
            import time as _time
            time = int(_time.time())
        action = {"step": step, "time": time}
        if choice:
            action["choice"] = choice
        self.actions.append(action)
        self.save()

class ACLSMedication(models.Model):
    """Separate model for medications to enable better querying and integrity."""
    session = models.ForeignKey(ACLSSession, on_delete=models.CASCADE, related_name='medications')
    medication = models.CharField(max_length=100)
    dose = models.CharField(max_length=50)  # Store as string to handle various formats
    administered_time = models.IntegerField()  # Unix timestamp
    created_at = models.DateTimeField(auto_now_add=True)

    class Meta:
        ordering = ['administered_time']
        indexes = [
            models.Index(fields=['session', 'medication']),
            models.Index(fields=['administered_time']),
        ]

    def __str__(self):
        return f"{self.medication} {self.dose} at {self.administered_time}"

# Keep the old add_medication method for backward compatibility
def add_medication(self, med, dose, time=None):
    if time is None:
        import time as _time
        time = int(_time.time())
    
    # Create medication record
    ACLSMedication.objects.create(
        session=self,
        medication=med,
        dose=dose,
        administered_time=time
    )

# Add the method to the ACLSSession class
ACLSSession.add_medication = add_medication
