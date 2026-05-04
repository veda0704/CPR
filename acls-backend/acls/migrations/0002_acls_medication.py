# Generated manually for ACLSMedication model

import django.db.models.deletion
from django.db import migrations, models


class Migration(migrations.Migration):

    dependencies = [
        ('acls', '0001_initial'),
    ]

    operations = [
        migrations.RemoveField(
            model_name='aclssession',
            name='medications',
        ),
        migrations.CreateModel(
            name='ACLSMedication',
            fields=[
                ('id', models.BigAutoField(auto_created=True, primary_key=True, serialize=False, verbose_name='ID')),
                ('medication', models.CharField(max_length=100)),
                ('dose', models.CharField(max_length=50)),
                ('administered_time', models.IntegerField()),
                ('created_at', models.DateTimeField(auto_now_add=True)),
                ('session', models.ForeignKey(on_delete=django.db.models.deletion.CASCADE, related_name='medications', to='acls.aclssession')),
            ],
            options={
                'ordering': ['administered_time'],
            },
        ),
        migrations.AddIndex(
            model_name='aclsmedication',
            index=models.Index(fields=['session', 'medication'], name='acls_aclsme_session__c4b8e8_idx'),
        ),
        migrations.AddIndex(
            model_name='aclsmedication',
            index=models.Index(fields=['administered_time'], name='acls_aclsme_adminis_4b8c4a_idx'),
        ),
    ]