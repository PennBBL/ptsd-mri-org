import os


def create_key(template, outtype=('nii.gz',), annotation_classes=None):
    if template is None or not template:
        raise ValueError('Template must be a valid format string')
    return template, outtype, annotation_classes


def infotodict(seqinfo):
    """Heuristic evaluator for determining which runs belong where

    allowed template fields - follow python string module:

    item: index within category
    subject: participant id
    seqitem: run number during scanning
    subindex: sub index within group
    """

    last_run = len(seqinfo)
    
    # Create Keys
    t1w = create_key('sub-{subject}/{session}_{item}/anat/sub-{subject}-{session}_T1w')
    t2w = create_key('sub-{subject}/{session}/anat/sub-{subject}-{session}_run-{item}_T2w')
    dwi = create_key('sub-{subject}/{session}/dwi/sub-{subject}-{session}_acq-multiband_dwi_run-{item}')
    
    # Field maps
    b0_phase = create_key('sub-{subject}/{session}/fmap/sub-{subject}-{session}_phasediff')
    b0_mag = create_key('sub-{subject}/{session}/fmap/sub-{subject}-{session}_magnitude')
    pe_rev = create_key(
        'sub-{subject}/{session}/fmap/sub-{subject}-{session}_acq-multiband_dir-j_epi')

    # fmri scans
    rest_sb = create_key(
                         'sub-{subject}/{session}/func/sub-{subject}-{session}_task-rest_acq-singleband_run-{item}_bold')
    fracback = create_key(
       'sub-{subject}/{session}/func/sub-{subject}-{session}_task-swm_acq-singleband_run-{item}_bold')

    info = {t1w:[], t2w:[], dwi:[], b0_phase:[],
            b0_mag:[], pe_rev:[], rest_sb:[],
            fracback:[]}
    for s in seqinfo:
        protocol = s.protocol_name.lower()
        if "mprage" in protocol:
            info[t1w].append(s.series_id)
        if "t2_space" in protocol:
            info[t2w].append(s.series_id)
		

        elif "mapping" in protocol and "M" in s.image_type:
            info[b0_mag].append(s.series_id)
        elif "mapping" in protocol and "P" in s.image_type:
            info[b0_phase].append(s.series_id)
        elif "topup_ref" in protocol:
            info[pe_rev].append(s.series_id)
        elif "ep2d_diff" in protocol and not s.is_derived:
            info[dwi].append(s.series_id)

        elif "swm" in protocol:
            info[fracback].append(s.series_id)
        elif "rest" in protocol:
            info[rest_sb].append(s.series_id)
    return info
