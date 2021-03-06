.. -*- mode: rst -*-

External projects used and papers to cite 
-----------------------------------------
sammba-mri is essentially a wrapper for a number of other tools, adapting them 
for use with small mammal brain MRI. There is not yet a publication about 
sammba-MRI itself. If you use it, please cite the tool name ``SaMmBa-MRI`` and 
the website address.

DICOM import uses the dcmdump tool of `OFFIS dcmtk 
<http://dicom.offis.de/dcmtk.php.en>`_. Export to NIfTI uses `nibabel 
<http://nipy.org/nibabel/>`_. Understanding the affine was greatly aided by
reading common.py from `dicom2nifti 
<http://dicom2nifti.readthedocs.io/en/latest/>`_.

Spatial normalization almost exclusively uses
`AFNI <https://afni.nimh.nih.gov/>`_, the exception being RATS, which is the 
usual option for the usually-used brain extraction step. If you do use RATS,
`cite the RATS reference papers.
<http://www.iibi.uiowa.edu/content/rats-rapid-automatic-tissue-segmentation-rodent-brain-mri>`_
File management and interfacing with these tools is handled by nipype (`website
<http://nipype.readthedocs.io/en/latest/>`_ and `paper
<https://www.ncbi.nlm.nih.gov/pubmed/21897815>`_).

Nilearn is the package integrated for analysis of fMRI data, and was also used 
generate all the plots shown in the examples section. Please read `how to  cite 
nilearn
<http://nilearn.github.io/authors.html#citing-nilearn>`_.


People
------
sammba-mri was developed by members of the `Multimodal Imaging of 
Neurodegenerative Diseases and therapies
<http://jacob.cea.fr/drf/ifrancoisjacob/Pages/Departements/MIRCen/themes/alzheimer-vieillissement-cerebral-modelisation.aspx>`_ 
(MINDt) team at the Molecular Imaging Research Center (MIRCen) of the French 
Alternative Energies and Atomic Energy Commission (CEA).

Internal initial working versions of the spatial normalization pipeline and 
automated measurement/processing for anatomical morphology, FAIR perfusion and 
resting state fMRI was developed by Nachiket Nadkarni using a mixture of shell 
scripts, python and R.

Salma Bougacha translated shell scripts into python leveraging nipype, plus set 
up the github repository and this website.

Anne-Sophie Hérard saved us a massive outsourcing fee and came up with the
name and acronym.


Funding
-------
This work was funded by the French Public Investment Bank’s “ROMANE” program, 
Association France Alzheimer and Fondation Plan Alzheimer.
