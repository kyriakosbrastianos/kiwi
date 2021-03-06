#================
# FILE          : xmlValidator.pm
#----------------
# PROJECT       : openSUSE Build-Service
# COPYRIGHT     : (c) 2012 SUSE LLC
#               :
# AUTHOR        : Robert Schweikert <rjschwei@suse.com>
#               :
# BELONGS TO    : Operating System images
#               :
# DESCRIPTION   : Unit test implementation for the KIWIXMLValidator module.
#               :
# STATUS        : Development
#----------------
package Test::kiwiXMLValidator;

use strict;
use warnings;

use Common::ktLog;
use Common::ktTestCase;
use base qw /Common::ktTestCase/;

use KIWIXMLValidator;

#==========================================
# Constructor
#------------------------------------------
sub new {
	# ...
	# Construct new test case
	# ---
	my $this = shift -> SUPER::new(@_);
	$this -> {dataDir} = $this -> getDataDir() . '/kiwiXMLValidator/';
	$this -> {schema} = $this -> getBaseDir() . '/../modules/KIWISchema.rng';
	$this -> {xslt} =  $this -> getBaseDir() . '/../xsl/master.xsl';

	return $this;
}

#==========================================
# test_archiveUnique
#------------------------------------------
sub test_archiveUnique {
	# ...
	# Test that the package uniqueness criteria is properly enforced
	# ---
	my $this = shift;
	my $kiwi = $this -> {kiwi};
	my @invalidConfigs = $this -> __getInvalidFiles('archiveUnique');
	my $expectedMsg;
	for my $iConfFile (@invalidConfigs) {
		my $validator = $this -> __getValidator($iConfFile);
		$this -> assert_not_null($validator);
		my $res = $validator -> validate();
		if ($iConfFile =~ /archiveUniqueInvalid_1.xml/) {
			$expectedMsg = "Archive 'myBins.tar' specified multiple times in "
				. 'same <packages> section.';
		}
		# TODO
		# implamenet archive with arch= test once 775603 is implemented
		#elsif ($iConfFile =~ /packageUniqueInvalid_2.xml/) {
		#    $expectedMsg = "Package 'myBins.' specified multiple times for "
		#        . "architecture 'ppc64' in same <packages> section.";
		#}
		my $msg = $kiwi -> getMessage();
		$this -> assert_str_equals($expectedMsg, $msg);
		my $msgT = $kiwi -> getMessageType();
		$this -> assert_str_equals('error', $msgT);
		my $state = $kiwi -> getState();
		$this -> assert_str_equals('failed', $state);
		# Test this condition last to get potential error messages
		$this -> assert_null($res);
	}
	my @validConfigs = $this -> __getValidFiles('archiveUnique');
	$this -> __verifyValid(@validConfigs);
	return;
}

#==========================================
# test_bootDescriptSet
#------------------------------------------
sub test_bootDescriptSet {
	# ...
	# Test that required boot attribute requirement is properly enforced
	# ---
	my $this = shift;
	my $kiwi = $this -> {kiwi};
	my @invalidConfigs = $this -> __getInvalidFiles('bootDescript');
	for my $iConfFile (@invalidConfigs) {
		my $validator = $this -> __getValidator($iConfFile);
		$validator -> validate();
		my $msg = $kiwi -> getMessage();
		my $specType;
		if ( $iConfFile =~ 'bootDescriptInvalid_1.xml' ) {
			$specType = 'iso';
		} elsif ( $iConfFile =~ 'bootDescriptInvalid_2.xml' ) {
			$specType = 'oem';
		} elsif ( $iConfFile =~ 'bootDescriptInvalid_3.xml' ) {
			$specType = 'pxe';
		} elsif ( $iConfFile =~ 'bootDescriptInvalid_4.xml' ) {
			$specType = 'split';
		} elsif ( $iConfFile =~ 'bootDescriptInvalid_5.xml' ) {
			$specType = 'vmx';
		}
		my $expectedMsg = "$specType requires initrd, but no 'boot' "
					. 'attribute specified.';
		$this -> assert_str_equals($expectedMsg, $msg);
		my $msgT = $kiwi -> getMessageType();
		$this -> assert_str_equals('error', $msgT);
		my $state = $kiwi -> getState();
		$this -> assert_str_equals('failed', $state);
		# Test this condition last to get potential error messages
		$this -> assert_not_null($validator);
	}
	my @validConfigs = $this -> __getValidFiles('bootDescript');
	$this -> __verifyValid(@validConfigs);
	return;
}

#==========================================
# test_ctorInvalidConfPath
#------------------------------------------
sub test_ctorInvalidConfPath {
	# ...
	# Provide invalid path for configuration file
	# ---
	my $this = shift;
	my $kiwi = $this -> {kiwi};
	my $validator = KIWIXMLValidator -> new(
		'/tmp',
		$this -> {dataDir} . 'revision.txt',
		$this -> {schema},
		$this -> {xslt}
	);
	$this -> assert_null($validator);
	my $msg = $kiwi -> getMessage();
	$this -> assert_str_equals(
		'Could not find specified configuration: /tmp',$msg
	);
	my $msgT = $kiwi -> getMessageType();
	$this -> assert_str_equals('error', $msgT);
	my $state = $kiwi -> getState();
	$this -> assert_str_equals('failed', $state);
	return;
}

#==========================================
# test_ctorInvalidRevPath
#------------------------------------------
sub test_ctorInvalidRevPath {
	# ...
	# Provide invalid path for revision file
	# ---
	my $this = shift;
	my $kiwi = $this -> {kiwi};
	my $validator = KIWIXMLValidator -> new(
		$this -> {dataDir} . 'genericValid.xml',
		'/tmp',
		$this -> {schema},
		$this -> {xslt}
	);
	$this -> assert_null($validator);
	my $msg = $kiwi -> getMessage();
	$this -> assert_str_equals(
		'Could not find specified revision file: /tmp',$msg
	);
	my $msgT = $kiwi -> getMessageType();
	$this -> assert_str_equals('error', $msgT);
	my $state = $kiwi -> getState();
	$this -> assert_str_equals('failed', $state);
	return;
}

#==========================================
# test_ctorInvalidSchemaPath
#------------------------------------------
sub test_ctorInvalidSchemaPath {
	# ...
	# Provide invalid path for schema file
	# ---
	my $this = shift;
	my $kiwi = $this -> {kiwi};
	my $validator = KIWIXMLValidator -> new(
		$this -> {dataDir} . 'genericValid.xml',
		$this -> {dataDir} . 'revision.txt',
		'/tmp',
		$this -> {xslt}
	);
	$this -> assert_null($validator);
	my $msg = $kiwi -> getMessage();
	$this -> assert_str_equals(
		'Could not find specified schema: /tmp',$msg
	);
	my $msgT = $kiwi -> getMessageType();
	$this -> assert_str_equals('error', $msgT);
	my $state = $kiwi -> getState();
	$this -> assert_str_equals('failed', $state);
	return;
}

#==========================================
# test_ctorInvalidXSLTPath
#------------------------------------------
sub test_ctorInvalidXSLTPath {
	# ...
	# Provide invalid path for XSLT file
	# ---
	my $this = shift;
	my $kiwi = $this -> {kiwi};
	my $validator = KIWIXMLValidator -> new(
		$this -> {dataDir} . 'genericValid.xml',
		$this -> {dataDir} . 'revision.txt',
		$this -> {schema},
		'/tmp'
	);
	$this -> assert_null($validator);
	my $msg = $kiwi -> getMessage();
	$this -> assert_str_equals(
		'Could not find specified transformation: /tmp',$msg
	);
	my $msgT = $kiwi -> getMessageType();
	$this -> assert_str_equals('error', $msgT);
	my $state = $kiwi -> getState();
	$this -> assert_str_equals('failed', $state);
	return;
}

#==========================================
# test_ctorValid
#------------------------------------------
sub test_ctorValid {
	# ...
	# Create a valid object
	# ---
	my $this = shift;
	my $kiwi = $this -> {kiwi};
	my $validator = KIWIXMLValidator -> new(
		$this -> {dataDir} . 'genericValid.xml',
		$this -> {dataDir} . 'revision.txt',
		$this -> {schema},
		$this -> {xslt}
	);
	my $msg = $kiwi -> getMessage();
	$this -> assert_str_equals('No messages set', $msg);
	my $msgT = $kiwi -> getMessageType();
	$this -> assert_str_equals('none', $msgT);
	my $state = $kiwi -> getState();
	$this -> assert_str_equals('No state set', $state);
	# Test this condition last to get potential error messages
	$this -> assert_not_null($validator);
	return;
}

#==========================================
# test_defaultProfileSpec
#------------------------------------------
sub test_defaultProfileSpec {
	# ...
	# Test that the one default profile setting requirement is properly
	# enforced
	# ---
	my $this = shift;
	my $kiwi = $this -> {kiwi};
	my @invalidConfigs = $this -> __getInvalidFiles('defaultProfile');
	for my $iConfFile (@invalidConfigs) {
		my $validator = $this -> __getValidator($iConfFile);
		$validator -> validate();
		my $msg = $kiwi -> getMessage();
		my $expectedMsg = 'Only one profile may be set as the default '
		. 'profile by using the "import" attribute.';
		$this -> assert_str_equals($expectedMsg, $msg);
		my $msgT = $kiwi -> getMessageType();
		$this -> assert_str_equals('error', $msgT);
		my $state = $kiwi -> getState();
		$this -> assert_str_equals('failed', $state);
		# Test this condition last to get potential error messages
		$this -> assert_not_null($validator);
	}
	my @validConfigs = $this -> __getValidFiles('defaultProfile');
	$this -> __verifyValid(@validConfigs);
	return;
}

#==========================================
# test_defaultTypeSpec
#------------------------------------------
sub test_defaultTypeSpec {
	# ...
	# Test that the one default <type> per <preferences> spec is properly
	# enforced
	# ---
	my $this = shift;
	my $kiwi = $this -> {kiwi};
	my @invalidConfigs = $this -> __getInvalidFiles('defaultType');
	for my $iConfFile (@invalidConfigs) {
		my $validator = $this -> __getValidator($iConfFile);
		$validator -> validate();
		my $msg = $kiwi -> getMessage();
		$this -> assert_str_equals(
			'Only one primary type may be specified per preferences section.',
			$msg
		);
		my $msgT = $kiwi -> getMessageType();
		$this -> assert_str_equals('error', $msgT);
		my $state = $kiwi -> getState();
		$this -> assert_str_equals('failed', $state);
		# Test this condition last to get potential error messages
		$this -> assert_not_null($validator);
	}
	my @validConfigs = $this -> __getValidFiles('defaultType');
	$this -> __verifyValid(@validConfigs);
	return;
}

#==========================================
# test_deleteArchive
#------------------------------------------
sub test_deleteArchive {
	# ...
	# Test that an error condition is generated when trying to delete
	# an archive.
	# ---
	my $this = shift;
	my $kiwi = $this -> {kiwi};
	my $configFile = $this -> {dataDir} . '/deleteArchive.xml';
	my $validator = $this -> __getValidator($configFile);
	my $res = $validator -> validate();
	my $msg = $kiwi -> getMessage();
	my $expected = 'Inconsistent data: specified archive for '
		. 'deletion. This is not supported.';
	$this -> assert_str_equals($expected, $msg);
	my $msgT = $kiwi -> getMessageType();
	$this -> assert_str_equals('error', $msgT);
	my $state = $kiwi -> getState();
	$this -> assert_str_equals('failed', $state);
	# Test this condition last to get potential error messages
	$this -> assert_null($res);
	return;
}

#==========================================
# test_deletePattern
#------------------------------------------
sub test_deletePattern {
	# ...
	# Test that an error condition is generated when trying to delete
	# patterns.
	# ---
	my $this = shift;
	my $kiwi = $this -> {kiwi};
	my $configFile = $this -> {dataDir} . '/deletePattern.xml';
	my $validator = $this -> __getValidator($configFile);
	my $res = $validator -> validate();
	my $msg = $kiwi -> getMessage();
	my $expected = 'Inconsistent data: specified pattern for '
		. 'deletion. This is not supported.';
	$this -> assert_str_equals($expected, $msg);
	my $msgT = $kiwi -> getMessageType();
	$this -> assert_str_equals('error', $msgT);
	my $state = $kiwi -> getState();
	$this -> assert_str_equals('failed', $state);
	# Test this condition last to get potential error messages
	$this -> assert_null($res);
	return;
}

#==========================================
# test_deleteProduct
#------------------------------------------
sub test_deleteProduct {
	# ...
	# Test that an error condition is generated when trying to delete
	# a product.
	# ---
	my $this = shift;
	my $kiwi = $this -> {kiwi};
	my $configFile = $this -> {dataDir} . '/deleteProduct.xml';
	my $validator = $this -> __getValidator($configFile);
	my $res = $validator -> validate();
	my $msg = $kiwi -> getMessage();
	my $expected = 'Inconsistent data: specified product for '
		. 'deletion. This is not supported.';
	$this -> assert_str_equals($expected, $msg);
	my $msgT = $kiwi -> getMessageType();
	$this -> assert_str_equals('error', $msgT);
	my $state = $kiwi -> getState();
	$this -> assert_str_equals('failed', $state);
	# Test this condition last to get potential error messages
	$this -> assert_null($res);
	return;
}

#==========================================
# test_displayName
#------------------------------------------
sub test_displayName {
	# ...
	# Test that the display name condition is properly checked.
	# ---
	my $this = shift;
	my $kiwi = $this -> {kiwi};
	my @invalidConfigs = $this -> __getInvalidFiles('displayName');
	for my $iConfFile (@invalidConfigs) {
		my $validator = $this -> __getValidator($iConfFile);
		$validator -> validate();
		my $msg = $kiwi -> getMessage();
		my $expectedMsg = 'Found white space in string provided as '
		. 'displayname. No white space permitted';
		$this -> assert_str_equals($expectedMsg, $msg);
		my $msgT = $kiwi -> getMessageType();
		$this -> assert_str_equals('error', $msgT);
		my $state = $kiwi -> getState();
		$this -> assert_str_equals('failed', $state);
		# Test this condition last to get potential error messages
		$this -> assert_not_null($validator);
	}
	my @validConfigs = $this -> __getValidFiles('displayName');
	$this -> __verifyValid(@validConfigs);
	return;
}

#==========================================
# test_ec2IsFileSys
#------------------------------------------
sub test_ec2IsFileSys {
	# ...
	# Test that the image type for the EC2 format is a file system image
	# ---
	my $this = shift;
	my $kiwi = $this -> {kiwi};
	my @invalidConfigs = $this -> __getInvalidFiles('ec2IsFS');
	for my $iConfFile (@invalidConfigs) {
		my $validator = $this -> __getValidator($iConfFile);
		$validator -> validate();
		my $msg = $kiwi -> getMessage();
		my $expectedMsg = 'For EC2 image creation the image type must be '
			. 'one of the following supported file systems: ext2 ext3 '
			. 'ext4 reiserfs';
		my @supportedFS = qw /ext2 ext3 ext4 reiserfs/;
		$this -> assert_str_equals($expectedMsg, $msg);
		my $msgT = $kiwi -> getMessageType();
		$this -> assert_str_equals('error', $msgT);
		my $state = $kiwi -> getState();
		$this -> assert_str_equals('failed', $state);
		# Test this condition last to get potential error messages
		$this -> assert_not_null($validator);
	}
	my @validConfigs = $this -> __getValidFiles('ec2IsFS');
	$this -> __verifyValid(@validConfigs);
	return;
}

#==========================================
# test_ec2Regions
#------------------------------------------
sub test_ec2Regions {
	# ...
	# Test that the region names and uniqueness conditions are properly
	# enforced.
	# ---
	my $this = shift;
	my $kiwi = $this -> {kiwi};
	my @invalidConfigs = $this -> __getInvalidFiles('ec2Region');
	for my $iConfFile (@invalidConfigs) {
		my $validator = $this -> __getValidator($iConfFile);
		$validator -> validate();
		my $msg = $kiwi -> getMessage();
		my $expectedMsg;
		my @supportedRegions =
				qw /AP-Northeast AP-Southeast EU-West SA-East US-East/;
		push  @supportedRegions, qw /US-West US-West2/;
		if ( $iConfFile =~ 'ec2RegionInvalid_1.xml' ) {
			$expectedMsg = 'Specified region EU-West not unique';
		} else {
			$expectedMsg = "Only one of @supportedRegions may be specified "
			. 'as ec2region';
		}
		$this -> assert_str_equals($expectedMsg, $msg);
		my $msgT = $kiwi -> getMessageType();
		$this -> assert_str_equals('error', $msgT);
		my $state = $kiwi -> getState();
		$this -> assert_str_equals('failed', $state);
		# Test this condition last to get potential error messages
		$this -> assert_not_null($validator);
	}
	my @validConfigs = $this -> __getValidFiles('ec2Region');
	$this -> __verifyValid(@validConfigs);
	return;
}

#==========================================
# test_groupSettingConsistency
#------------------------------------------
sub test_groupSettingConsistency {
	# ...
	# Verify that inconsistent group definitions trigger the expected error
	# ---
	my $this = shift;
	my $kiwi = $this -> {kiwi};
	my @invalidConfigs = $this -> __getInvalidFiles('groupDefinition');
	my $expected;
	for my $iConfFile (@invalidConfigs) {
		my $validator = $this -> __getValidator($iConfFile);
		$this -> assert_not_null($validator);
		my $res = $validator -> validate();
		my $msg = $kiwi -> getMessage();
		if ( $iConfFile =~ '.*Invalid_1.xml') {
			$expected = "Group 'mygrp' specified with different ids, "
				. 'cannot resolve ambiguity.';
		}
		if ( $iConfFile =~ '.*Invalid_2.xml') {
			$expected = "Group ID '1135' specified twice, cannot resolve "
				. 'ambiguity.';
		}
		$this -> assert_str_equals($expected, $msg);
		my $msgT = $kiwi -> getMessageType();
		$this -> assert_str_equals('error', $msgT);
		my $state = $kiwi -> getState();
		$this -> assert_str_equals('failed', $state);
		# Test this condition last to get potential error messages
		$this -> assert_null($res);
	}
	my @validConfigs = $this -> __getValidFiles('groupDefinition');
	$this -> __verifyValid(@validConfigs);
	return;
}

#==========================================
# test_httpsRepoCredentials
#------------------------------------------
sub test_httpsRepoCredentials {
	# ...
	# Test proper enforcement of the credential rules for repositories.
	# Repositories with username attribute must have password attribute and
	# vice versa
	# All https repositories must have the same credentials.
	# ---
	my $this = shift;
	my $kiwi = $this -> {kiwi};
	my @invalidConfigs = $this -> __getInvalidFiles('httpsRepoCredentials');
	my $expectedMsg;
	for my $iConfFile (@invalidConfigs) {
		my $validator = $this -> __getValidator($iConfFile);
		$this -> assert_not_null($validator);
		my $res = $validator -> validate();
		my $msg = $kiwi -> getMessage();
		if ($iConfFile =~ /httpsRepoCredentialsInvalid_1|5.xml/) {
			$expectedMsg = 'Specified username without password on repository';
			
		} elsif ($iConfFile =~ /httpsRepoCredentialsInvalid_2|6.xml/) {
			$expectedMsg = 'Specified password without username on repository';
		} elsif ($iConfFile =~ /httpsRepoCredentialsInvalid_3.xml/) {
			$expectedMsg = 'Specified username, someoneelse, for https '
			. 'repository does not match previously specified name, itsme. '
			. 'All credentials for https repositories must be equal.';
		} elsif ($iConfFile =~ /httpsRepoCredentialsInvalid_4.xml/) {
			$expectedMsg = 'Specified password, another, for https repository '
			. 'does not match previously specified password, heythere. All '
			. 'credentials for https repositories must be equal.';
		} else {
			$expectedMsg = 'Should not get here.';
		}
		$this -> assert_str_equals($expectedMsg, $msg);
		my $msgT = $kiwi -> getMessageType();
		$this -> assert_str_equals('error', $msgT);
		my $state = $kiwi -> getState();
		$this -> assert_str_equals('failed', $state);
		# Test this condition last to get potential error messages
		$this -> assert_null($res);
	}
	my @validConfigs = $this -> __getValidFiles('httpsRepoCredentials');
	$this -> __verifyValid(@validConfigs);
	return;
}

#==========================================
# test_missingFilesysAttr
#------------------------------------------
sub test_missingFilesysAttr {
	# ...
	# Test that the filesystem attribute is set when required
	# ---
	my $this = shift;
	my $kiwi = $this -> {kiwi};
	my @invalidConfigs = $this -> __getInvalidFiles('missingFilesysAttr');
	for my $iConfFile (@invalidConfigs) {
		my $validator = $this -> __getValidator($iConfFile);
		$validator -> validate();
		my $msg = $kiwi -> getMessage();
		my $expectedMsg = 'filesystem attribute must be set for image="';
		if ($iConfFile =~ /missingFilesysAttrInvalid_1.xml/) {
			$expectedMsg .= 'oem"';
		} elsif ($iConfFile =~ /missingFilesysAttrInvalid_2.xml/) {
			$expectedMsg .= 'vmx"';
		}
		$this -> assert_str_equals($expectedMsg, $msg);
		my $msgT = $kiwi -> getMessageType();
		$this -> assert_str_equals('error', $msgT);
		my $state = $kiwi -> getState();
		$this -> assert_str_equals('failed', $state);
		# Test this condition last to get potential error messages
		$this -> assert_not_null($validator);
	}
	my @validConfigs = $this -> __getValidFiles('missingFilesysAttr');
	$this -> __verifyValid(@validConfigs);
	return;
}

#==========================================
# test_netInterfaceMACUnique
#------------------------------------------
sub test_netInterfaceMACUnique {
	# ...
	# Test that a given interface MAC is unique within one <machine>
	# definition.
	# ---
	my $this = shift;
	my $kiwi = $this -> {kiwi};
	my @invalidConfigs = $this -> __getInvalidFiles('netIfaceUniqueMAC');
	for my $iConfFile (@invalidConfigs) {
		my $validator = $this -> __getValidator($iConfFile);
		$validator -> validate();
		my $msg = $kiwi -> getMessage();
		my $expected = "Interface '00:0C:6E:AA:57:2F' assigned twice.";
		$this -> assert_str_equals($expected, $msg);
		my $msgT = $kiwi -> getMessageType();
		$this -> assert_str_equals('error', $msgT);
		my $state = $kiwi -> getState();
		$this -> assert_str_equals('failed', $state);
		# Test this condition last to get potential error messages
		$this -> assert_not_null($validator);
	}
	my @validConfigs = $this -> __getValidFiles('netIfaceUniqueMAC');
	$this -> __verifyValid(@validConfigs);
	return;
}

#==========================================
# test_netInterfaceNameUnique
#------------------------------------------
sub test_netInterfaceNameUnique {
	# ...
	# Test that a given interface name is unique within one <machine>
	# definition.
	# ---
	my $this = shift;
	my $kiwi = $this -> {kiwi};
	my @invalidConfigs = $this -> __getInvalidFiles('netIfaceUnique');
	for my $iConfFile (@invalidConfigs) {
		my $validator = $this -> __getValidator($iConfFile);
		$validator -> validate();
		my $msg = $kiwi -> getMessage();
		my $expected = "Interface 'br0' assigned twice.";
		$this -> assert_str_equals($expected, $msg);
		my $msgT = $kiwi -> getMessageType();
		$this -> assert_str_equals('error', $msgT);
		my $state = $kiwi -> getState();
		$this -> assert_str_equals('failed', $state);
		# Test this condition last to get potential error messages
		$this -> assert_not_null($validator);
	}
	my @validConfigs = $this -> __getValidFiles('netIfaceUnique');
	$this -> __verifyValid(@validConfigs);
	return;
}

#==========================================
# test_noIDSystemGroups
#------------------------------------------
sub test_noIDSystemGroups {
	# ...
	# Test that specifying a group ID for a group created by the install
	# creates an error
	# ---
	my $this = shift;
	my $kiwi = $this -> {kiwi};
	my @invalidConfigs = $this -> __getInvalidFiles('noIDSysGrp');
	for my $iConfFile (@invalidConfigs) {
		my $validator = $this -> __getValidator($iConfFile);
		$validator -> validate();
		my $msg = $kiwi -> getMessage();
		my $expected = "Assigning ID to system group 'video' not allowed.";
		$this -> assert_str_equals($expected, $msg);
		my $msgT = $kiwi -> getMessageType();
		$this -> assert_str_equals('error', $msgT);
		my $state = $kiwi -> getState();
		$this -> assert_str_equals('failed', $state);
		# Test this condition last to get potential error messages
		$this -> assert_not_null($validator);
	}
	return;
}

#==========================================
# test_noBootVolume
#------------------------------------------
sub test_noBootVolume {
	# ...
	# Test that the specification of "boot" as a volume is flagged as
	# as an error.
	# ---
	my $this = shift;
	my $kiwi = $this -> {kiwi};
	my @invalidConfigs = $this -> __getInvalidFiles('noBootVolume');
	for my $iConfFile (@invalidConfigs) {
		my $validator = $this -> __getValidator($iConfFile);
		$validator -> validate();
		my $msg = $kiwi -> getMessage();
		my $expected = 'Found <systemdisk> setup using "/boot" as '
			. 'volume. This is not supported.';
		$this -> assert_str_equals($expected, $msg);
		my $msgT = $kiwi -> getMessageType();
		$this -> assert_str_equals('error', $msgT);
		my $state = $kiwi -> getState();
		$this -> assert_str_equals('failed', $state);
		# Test this condition last to get potential error messages
		$this -> assert_not_null($validator);
	}
	my @validConfigs = $this -> __getValidFiles('noBootVolume');
	$this -> __verifyValid(@validConfigs);
	return;
}

#==========================================
# test_oemPostDump
#------------------------------------------
sub test_oemPostDump {
	# ...
	# Test that the oem post dump action uniqueness is properly
	# enforced.
	# ---
	my $this = shift;
	my $kiwi = $this -> {kiwi};
	my @invalidConfigs = $this -> __getInvalidFiles('oemPostDump');
	for my $iConfFile (@invalidConfigs) {
		my $validator = $this -> __getValidator($iConfFile);
		$validator -> validate();
		my $msg = $kiwi -> getMessage();
		my $expectedMsg = 'Use one of oem-reboot '
		. 'oem-reboot-interactive oem-shutdown oem-shutdown-interactive';
		$this -> assert_str_equals($expectedMsg, $msg);
		my $msgT = $kiwi -> getMessageType();
		$this -> assert_str_equals('error', $msgT);
		my $state = $kiwi -> getState();
		$this -> assert_str_equals('failed', $state);
		# Test this condition last to get potential error messages
		$this -> assert_not_null($validator);
	}
	my @validConfigs = $this -> __getValidFiles('oemPostDump');
	$this -> __verifyValid(@validConfigs);
	return;
}

#==========================================
# test_packageUnique
#------------------------------------------
sub test_packageUnique {
	# ...
	# Test that the package uniqueness criteria is properly enforced
	# ---
	my $this = shift;
	my $kiwi = $this -> {kiwi};
	my @invalidConfigs = $this -> __getInvalidFiles('packageUnique');
	my $expectedMsg;
	for my $iConfFile (@invalidConfigs) {
		my $validator = $this -> __getValidator($iConfFile);
		$validator -> validate();
		if ($iConfFile =~ /packageUniqueInvalid_1.xml/) {
			$expectedMsg = "Package 'vim' specified multiple times in "
				. 'same <packages> section.';
		} elsif ($iConfFile =~ /packageUniqueInvalid_2.xml/) {
			$expectedMsg = "Package 'vim' specified multiple times for "
				. "architecture 'ppc64' in same <packages> section.";
		}
		my $msg = $kiwi -> getMessage();
		$this -> assert_str_equals($expectedMsg, $msg);
		my $msgT = $kiwi -> getMessageType();
		$this -> assert_str_equals('error', $msgT);
		my $state = $kiwi -> getState();
		$this -> assert_str_equals('failed', $state);
		# Test this condition last to get potential error messages
		$this -> assert_not_null($validator);
	}
	my @validConfigs = $this -> __getValidFiles('packageUnique');
	$this -> __verifyValid(@validConfigs);
	return;
}

#==========================================
# test_patternUnique
#------------------------------------------
sub test_patternUnique {
	# ...
	# Test that the package uniqueness criteria is properly enforced
	# ---
	my $this = shift;
	my $kiwi = $this -> {kiwi};
	my @invalidConfigs = $this -> __getInvalidFiles('patternUnique');
	my $expectedMsg;
	for my $iConfFile (@invalidConfigs) {
		my $validator = $this -> __getValidator($iConfFile);
		$validator -> validate();
		if ($iConfFile =~ /patternUniqueInvalid_1.xml/) {
			$expectedMsg = "Package pattern 'kde' specified multiple times in "
				. 'same <packages> section.';
		} elsif ($iConfFile =~ /patternUniqueInvalid_2.xml/) {
			$expectedMsg = "Package pattern 'kde' specified multiple times "
				. "for architecture 's390' in same <packages> section.";
		}
		my $msg = $kiwi -> getMessage();
		$this -> assert_str_equals($expectedMsg, $msg);
		my $msgT = $kiwi -> getMessageType();
		$this -> assert_str_equals('error', $msgT);
		my $state = $kiwi -> getState();
		$this -> assert_str_equals('failed', $state);
		# Test this condition last to get potential error messages
		$this -> assert_not_null($validator);
	}
	my @validConfigs = $this -> __getValidFiles('patternUnique');
	$this -> __verifyValid(@validConfigs);
	return;
}

#==========================================
# test_patternTattrConsistent
#------------------------------------------
sub test_patternTattrConsistent {
	# ...
	# Test that the patternType attribute consistency criteria is
	# properly enforced.
	# ---
	my $this = shift;
	my $kiwi = $this -> {kiwi};
	my @invalidConfigs = $this -> __getInvalidFiles('patternTattrCons');
	for my $iConfFile (@invalidConfigs) {
		my $validator = $this -> __getValidator($iConfFile);
		$validator -> validate();
		my $msg = $kiwi -> getMessage();
		my $expectedMsg;
		if ($iConfFile =~ /patternTattrConsInvalid_1.xml/) {
			$expectedMsg = 'Conflicting patternType attribute values for '
			. '"my-second" profile found.';
		} elsif ($iConfFile =~ /patternTattrConsInvalid_2.xml/) {
			$expectedMsg = 'Conflicting patternType attribute values for '
			. '"my-first" profile found.';
		} elsif ($iConfFile =~ /patternTattrConsInvalid_3.xml/) {
			$expectedMsg = 'The specified value "plusRecommended" for the '
			. 'patternType attribute differs from the specified default '
			. 'value: "onlyRequired".';
		} elsif ($iConfFile =~ /patternTattrConsInvalid_4.xml/) {
			$expectedMsg = 'The patternType attribute was omitted, but the '
			. 'base <packages> specification requires "plusRecommended" '
			. 'the values must match.';
		} else {
			# Force a test failure, there is no generic message in this test
			# stream
			$expectedMsg = 'ola';
		}
		$this -> assert_str_equals($expectedMsg, $msg);
		my $msgT = $kiwi -> getMessageType();
		$this -> assert_str_equals('error', $msgT);
		my $state = $kiwi -> getState();
		$this -> assert_str_equals('failed', $state);
		# Test this condition last to get potential error messages
		$this -> assert_not_null($validator);
	}
	my @validConfigs = $this -> __getValidFiles('patternTattrCons');
	$this -> __verifyValid(@validConfigs);
	return;
}

#==========================================
# test_patternTattrUse
#------------------------------------------
sub test_patternTattrUse {
	# ...
	# Test that the patternType attribute use criteria is properly
	# enforced.
	# ---
	my $this = shift;
	my $kiwi = $this -> {kiwi};
	my @invalidConfigs = $this -> __getInvalidFiles('patternTattrUse');
	for my $iConfFile (@invalidConfigs) {
		my $validator = $this -> __getValidator($iConfFile);
		$validator -> validate();
		my $msg = $kiwi -> getMessage();
		my $expectedMsg = 'The patternType atribute is not allowed on a '
		. '<packages> specification of type delete.';
		$this -> assert_str_equals($expectedMsg, $msg);
		my $msgT = $kiwi -> getMessageType();
		$this -> assert_str_equals('error', $msgT);
		my $state = $kiwi -> getState();
		$this -> assert_str_equals('failed', $state);
		# Test this condition last to get potential error messages
		$this -> assert_not_null($validator);
	}
	my @validConfigs = $this -> __getValidFiles('patternTattrUse');
	$this -> __verifyValid(@validConfigs);
	return;
}

#==========================================
# test_preferLicenseUnique
#------------------------------------------
sub test_preferLicenseUnique {
	# ...
	# Test that the verification of the singular setting of prefer-license
	# is enforced.
	# ---
	my $this = shift;
	my $kiwi = $this -> {kiwi};
	my @invalidConfigs = $this -> __getInvalidFiles('preferLic');
	my $expectedMsg = 'Ambiguous license preference defined. Cannot resolve '
		. 'prefer-license=true for 2 or repositories.';
	for my $iConfFile (@invalidConfigs) {
		my $validator = $this -> __getValidator($iConfFile);
		$validator -> validate();
		my $msg = $kiwi -> getMessage();
		$this -> assert_str_equals($expectedMsg, $msg);
		my $msgT = $kiwi -> getMessageType();
		$this -> assert_str_equals('error', $msgT);
		my $state = $kiwi -> getState();
		$this -> assert_str_equals('failed', $state);
		# Test this condition last to get potential error messages
		$this -> assert_not_null($validator);
	}
	my @validConfigs = $this -> __getValidFiles('preferLic');
	$this -> __verifyValid(@validConfigs);
	return;
}


#==========================================
# test_preferenceUnique
#------------------------------------------
sub test_preferenceUnique {
	# ...
	# Test that the <preferences> element uniqueness criteria is properly
	# enforced.
	# ---
	my $this = shift;
	my $kiwi = $this -> {kiwi};
	my @invalidConfigs = $this -> __getInvalidFiles('preferenceUnique');
	for my $iConfFile (@invalidConfigs) {
		my $validator = $this -> __getValidator($iConfFile);
		$validator -> validate();
		my $msg = $kiwi -> getMessage();
		my $expectedMsg;
		if ($iConfFile =~ /preferenceUniqueInvalid_1.xml/) {
			$expectedMsg = 'Specify only one <preferences> element without '
		. 'using the "profiles" attribute.';
		} elsif ($iConfFile =~ /preferenceUniqueInvalid_2.xml/) {
			$expectedMsg = 'Only one <preferences> element may reference a '
			. 'given profile. xenFlavor referenced multiple times.';
		}
		$this -> assert_str_equals($expectedMsg, $msg);
		my $msgT = $kiwi -> getMessageType();
		$this -> assert_str_equals('error', $msgT);
		my $state = $kiwi -> getState();
		$this -> assert_str_equals('failed', $state);
		# Test this condition last to get potential error messages
		$this -> assert_not_null($validator);
	}
	my @validConfigs = $this -> __getValidFiles('preferenceUnique');
	$this -> __verifyValid(@validConfigs);
	return;
}

#==========================================
# test_profileName
#------------------------------------------
sub test_profileName {
	# ...
	# Test that the profile name convention is enforced properly.
	# ---
	my $this = shift;
	my $kiwi = $this -> {kiwi};
	my @invalidConfigs = $this -> __getInvalidFiles('profileName');
	for my $iConfFile (@invalidConfigs) {
		my $validator = $this -> __getValidator($iConfFile);
		$validator -> validate();
		my $msg = $kiwi -> getMessage();
		my $expectedMsg ;
		if ($iConfFile =~ /profileNameInvalid_2.xml/) {
			$expectedMsg = "Name of a profile may not be set to 'all'.";
		} elsif ($iConfFile =~ /profileNameInvalid_3.xml/) {
			$expectedMsg = 'Name of a profile may not be set to '
				. "'kiwi_default'.";
		} else {
			$expectedMsg = 'Name of a profile may not contain whitespace.';
		}
		$this -> assert_str_equals($expectedMsg, $msg);
		my $msgT = $kiwi -> getMessageType();
		$this -> assert_str_equals('error', $msgT);
		my $state = $kiwi -> getState();
		$this -> assert_str_equals('failed', $state);
		# Test this condition last to get potential error messages
		$this -> assert_not_null($validator);
	}
	my @validConfigs = $this -> __getValidFiles('profileName');
	$this -> __verifyValid(@validConfigs);
	return;
}

#==========================================
# test_profileReferenceExist
#------------------------------------------
sub test_profileReferenceExist {
	# ...
	# Test that the existens requirement for a referenced profile is
	# properly enforced.
	# ---
	my $this = shift;
	my $kiwi = $this -> {kiwi};
	my @invalidConfigs = $this -> __getInvalidFiles('profileReferenceExist');
	for my $iConfFile (@invalidConfigs) {
		my $validator = $this -> __getValidator($iConfFile);
		$validator -> validate();
		my $msg = $kiwi -> getMessage();
		my $expectedMsg = 'Found reference to profile "';
		if ($iConfFile =~ /profileReferenceExistInvalid_(1|2).xml/) {
			$expectedMsg .= 'vmwFlavor';
		} elsif ($iConfFile =~ /profileReferenceExistInvalid_(3|4|5).xml/) {
			$expectedMsg .= 'ola';
		}
		$expectedMsg .= '" but this profile is not defined.';
		$this -> assert_str_equals($expectedMsg, $msg);
		my $msgT = $kiwi -> getMessageType();
		$this -> assert_str_equals('error', $msgT);
		my $state = $kiwi -> getState();
		$this -> assert_str_equals('failed', $state);
		# Test this condition last to get potential error messages
		$this -> assert_not_null($validator);
	}
	my @validConfigs = $this -> __getValidFiles('profileReferenceExist');
	$this -> __verifyValid(@validConfigs);
	return;
}

#==========================================
# test_revisionMismatch
#------------------------------------------
sub test_revisionMismatch {
	# ...
	# Test mismatch between specified revision and encoded revision
	# ---
	my $this = shift;
	my $validator = $this -> __getValidator(
		$this -> {dataDir} . 'improperRevision.xml'
	);
	$validator -> validate();
	my $kiwi = $this -> {kiwi};
	my $msg = $kiwi -> getMessage();
	$this -> assert_str_equals(
		"--> got: 1\n",$msg
	);
	my $msgT = $kiwi -> getMessageType();
	$this -> assert_str_equals('error', $msgT);
	my $state = $kiwi -> getState();
	$this -> assert_str_equals('failed', $state);
	# Test this condition last to get potential error messages
	$this -> assert_not_null($validator);
	return;
}

#==========================================
# test_sysdiskNameAttrNoWhiteSpace
#------------------------------------------
sub test_sysdiskNameAttrNoWhiteSpace {
	# ...
	# Test that the value of the name attribute of the <systemdisk>
	# element does not contain whitespace.
	# ---
	my $this = shift;
	my $kiwi = $this -> {kiwi};
	my @invalidConfigs = $this -> __getInvalidFiles('sysdiskWhitespace');
	my $expectedMsg = 'Found whitespace in name given for systemdisk. '
		. 'Provided name may not contain whitespace.';
	for my $iConfFile (@invalidConfigs) {
		my $validator = $this -> __getValidator($iConfFile);
		$validator -> validate();
		my $msg = $kiwi -> getMessage();
			$this -> assert_str_equals($expectedMsg, $msg);
		my $msgT = $kiwi -> getMessageType();
		$this -> assert_str_equals('error', $msgT);
		my $state = $kiwi -> getState();
		$this -> assert_str_equals('failed', $state);
		# Test this condition last to get potential error messages
		$this -> assert_not_null($validator);
	}
	my @validConfigs = $this -> __getValidFiles('sysdiskWhitespace');
	$this -> __verifyValid(@validConfigs);
	return;
}

#==========================================
# test_sysdiskInvalidAttrs
#------------------------------------------
sub test_sysdiskInvalidAttrs {
	# ...
	# Test that the use of the attributes size and freespace in combination
	# is rejected.
	# ---
	my $this = shift;
	my $kiwi = $this -> {kiwi};
	my @invalidConfigs = $this -> __getInvalidFiles('sysdiskVolAttrs');
	my $expectedMsg = 'Found combination of "size" and "freespace" attribute '
		. 'for volume element. This is not supported.';
	for my $iConfFile (@invalidConfigs) {
		my $validator = $this -> __getValidator($iConfFile);
		$validator -> validate();
		my $msg = $kiwi -> getMessage();
			$this -> assert_str_equals($expectedMsg, $msg);
		my $msgT = $kiwi -> getMessageType();
		$this -> assert_str_equals('error', $msgT);
		my $state = $kiwi -> getState();
		$this -> assert_str_equals('failed', $state);
		# Test this condition last to get potential error messages
		$this -> assert_not_null($validator);
	}
	my @validConfigs = $this -> __getValidFiles('sysdiskVolAttrs');
	$this -> __verifyValid(@validConfigs);
	return;
}

#==========================================
# test_typeConfigConsist
#------------------------------------------
sub test_typeConfigConsist {
	# ...
	# Test that the image type configuration consistency is
	# properly enforced.
	# ---
	my $this = shift;
	my $kiwi = $this -> {kiwi};
	my @invalidConfigs = $this -> __getInvalidFiles('typeConfigConsist');
	for my $iConfFile (@invalidConfigs) {
		my $validator = $this -> __getValidator($iConfFile);
		$validator -> validate();
		my $msg = $kiwi -> getMessage();
		my $expectedMsg = 'Inconsistent configuration: Found ';
		if ($iConfFile =~ /typeConfigConsistInvalid_1.xml/) {
			$expectedMsg .= 'machine';
		} elsif ($iConfFile =~ /typeConfigConsistInvalid_2.xml/) {
			$expectedMsg .= 'oemconfig';
		}
		$expectedMsg .= " type configuration as child of image type ";
		if ($iConfFile =~ /typeConfigConsistInvalid_1.xml/) {
			$expectedMsg .= 'pxe.';
		} elsif ($iConfFile =~ /typeConfigConsistInvalid_2.xml/) {
			$expectedMsg .= 'vmx.';
		}
		$this -> assert_str_equals($expectedMsg, $msg);
		my $msgT = $kiwi -> getMessageType();
		$this -> assert_str_equals('error', $msgT);
		my $state = $kiwi -> getState();
		$this -> assert_str_equals('failed', $state);
		# Test this condition last to get potential error messages
		$this -> assert_not_null($validator);
	}
	my @validConfigs = $this -> __getValidFiles('typeUnique');
	$this -> __verifyValid(@validConfigs);
	return;
}

#==========================================
# test_typePackTypeExists
#------------------------------------------
sub test_typePackTypeExists {
	# ...
	# Test that packages can only be specified for types that
	# have been defined
	# ---
	my $this = shift;
	my $kiwi = $this -> {kiwi};
	my @invalidConfigs = $this -> __getInvalidFiles('typePcksTypeExists');
	for my $iConfFile (@invalidConfigs) {
		my $validator = $this -> __getValidator($iConfFile);
		$validator -> validate();
		my $msg = $kiwi -> getMessage();
		my $expectedMsg;
		if ( $iConfFile =~ 'typePcksTypeExistsInvalid_1.xml' ) {
			$expectedMsg = "Specified packages for type 'oem' "
				. 'but this type is not defined for the default image';
		}
		if ( $iConfFile =~ 'typePcksTypeExistsInvalid_2.xml' ) {
			$expectedMsg = 'Found reference to profile "profD" '
				. "but this profile is not defined.";
		}
		if ( $iConfFile =~ 'typePcksTypeExistsInvalid_3.xml' ) {
			$expectedMsg = "Specified packages for type 'split' "
				. "but this type is not defined for profile 'profA'";
		}
		$this -> assert_str_equals($expectedMsg, $msg);
		my $msgT = $kiwi -> getMessageType();
		$this -> assert_str_equals('error', $msgT);
		my $state = $kiwi -> getState();
		$this -> assert_str_equals('failed', $state);
		# Test this condition last to get potential error messages
		$this -> assert_not_null($validator);
	}
	my @validConfigs = $this -> __getValidFiles('typePcksTypeExists');
	$this -> __verifyValid(@validConfigs);
	return;
}

#==========================================
# test_typeUnique
#------------------------------------------
sub test_typeUnique {
	# ...
	# Test that the image type uniqueness requirement is
	# properly enforced.
	# ---
	my $this = shift;
	my $kiwi = $this -> {kiwi};
	my @invalidConfigs = $this -> __getInvalidFiles('typeUnique');
	for my $iConfFile (@invalidConfigs) {
		my $validator = $this -> __getValidator($iConfFile);
		$validator -> validate();
		my $msg = $kiwi -> getMessage();
		my $expectedMsg = 'Multiple definition of <type image="';
		if ($iConfFile =~ /typeUniqueInvalid_1.xml/) {
			$expectedMsg .= 'iso';
		} elsif ($iConfFile =~ /typeUniqueInvalid_2.xml/) {
			$expectedMsg .= 'oem';
		}
		$expectedMsg .= '".../> found.';
		$this -> assert_str_equals($expectedMsg, $msg);
		my $msgT = $kiwi -> getMessageType();
		$this -> assert_str_equals('error', $msgT);
		my $state = $kiwi -> getState();
		$this -> assert_str_equals('failed', $state);
		# Test this condition last to get potential error messages
		$this -> assert_not_null($validator);
	}
	my @validConfigs = $this -> __getValidFiles('typeUnique');
	$this -> __verifyValid(@validConfigs);
	return;
}

#==========================================
# test_versionFormat
#------------------------------------------
sub test_versionFormat {
	# ...
	# Test that the version number format requirement is
	# properly enforced.
	# ---
	my $this = shift;
	my $kiwi = $this -> {kiwi};
	my @invalidConfigs = $this -> __getInvalidFiles('versionFormat');
	for my $iConfFile (@invalidConfigs) {
		my $validator = $this -> __getValidator($iConfFile);
		$validator -> validate();
		my $msg = $kiwi -> getMessage();
		my $expectedMsg = "Expected 'Major.Minor.Release'";
		$this -> assert_str_equals($expectedMsg, $msg);
		my $msgT = $kiwi -> getMessageType();
		$this -> assert_str_equals('error', $msgT);
		my $state = $kiwi -> getState();
		$this -> assert_str_equals('failed', $state);
		# Test this condition last to get potential error messages
		$this -> assert_not_null($validator);
	}
	my @validConfigs = $this -> __getValidFiles('versionFormat');
	$this -> __verifyValid(@validConfigs);
	return;
}

#==========================================
# test_userDefinitionConsistent
#------------------------------------------
sub test_userDefinitionConsistent {
	# ...
	# Test that inconsistent user definitions are properly detected
	# ---
	my $this = shift;
	my $kiwi = $this -> {kiwi};
	my @invalidConfigs = $this -> __getInvalidFiles('userDefinition');
	my $expected;
	for my $iConfFile (@invalidConfigs) {
		my $validator = $this -> __getValidator($iConfFile);
		$this -> assert_not_null($validator);
		my $res = $validator -> validate();
		my $msg = $kiwi -> getMessage();
		if ($iConfFile =~ /.*Invalid_1.xml/) {
			$expected = 'Specified user name contains whitspace, this '
				. 'is not supported.';
		}
		if ($iConfFile =~ /.*Invalid_2.xml/) {
			$expected = 'Specified home directory contains whitspace, '
				. 'this is not supported.';
		}
		if ($iConfFile =~ /.*Invalid_3.xml/) {
			$expected = 'Specified login shell contains whitspace, '
				. 'this is not supported.';
		}
		if ($iConfFile =~ /.*Invalid_4.xml/) {
			$expected = 'Same user defined in a single group, '
				. 'cannot resolve ambiguity.';
		}
		if ($iConfFile =~ /.*Invalid_5.xml/) {
			$expected = 'Same user defined in two groups with '
				. 'given groupid, cannot resolve ambiguity.';
		}
		if ($iConfFile =~ /.*Invalid_6.xml/) {
			$expected = 'Same user specified with different home '
				. 'directories, cannot resolve ambiguity.';
		}
		if ($iConfFile =~ /.*Invalid_7.xml/) {
			$expected = 'Same user specified with different '
				. 'passwords, cannot resolve ambiguity.';
		}
		if ($iConfFile =~ /.*Invalid_8.xml/) {
			$expected = 'Same user specified with different '
				. 'password formats, cannot resolve ambiguity.';
		}
		if ($iConfFile =~ /.*Invalid_9.xml/) {
			$expected = 'Same user specified with different '
				. 'real names, cannot resolve ambiguity.';
		}
		if ($iConfFile =~ /.*Invalid_10.xml/) {
			$expected = 'Same user specified with different '
				. 'shells, cannot resolve ambiguity.';
		}
		if ($iConfFile =~ /.*Invalid_11.xml/) {
			$expected = 'Same user specified with different '
				. 'user ids, cannot resolve ambiguity.';
		}
		$this -> assert_str_equals($expected, $msg);
		my $msgT = $kiwi -> getMessageType();
		$this -> assert_str_equals('error', $msgT);
		my $state = $kiwi -> getState();
		$this -> assert_str_equals('failed', $state);
		# Test this condition last to get potential error messages
		$this -> assert_null($res);
	}
	my @validConfigs = $this -> __getValidFiles('userDefinition');
	$this -> __verifyValid(@validConfigs);
	return;
}

#==========================================
# test_volumeNameAttrNoWhiteSpace
#------------------------------------------
sub test_volumeNameAttrNoWhiteSpace {
	# ...
	# Test that the value of the name attribute of the <volume>
	# element does not contain whitespace.
	# ---
	my $this = shift;
	my $kiwi = $this -> {kiwi};
	my @invalidConfigs = $this -> __getInvalidFiles('volumeWhitespace');
	my $expectedMsg = 'Found whitespace in given volume name. '
		. 'Provided name may not contain whitespace.';
	for my $iConfFile (@invalidConfigs) {
		my $validator = $this -> __getValidator($iConfFile);
		$validator -> validate();
		my $msg = $kiwi -> getMessage();
		$this -> assert_str_equals($expectedMsg, $msg);
		my $msgT = $kiwi -> getMessageType();
		$this -> assert_str_equals('error', $msgT);
		my $state = $kiwi -> getState();
		$this -> assert_str_equals('failed', $state);
		# Test this condition last to get potential error messages
		$this -> assert_not_null($validator);
	}
	my @validConfigs = $this -> __getValidFiles('volumeWhitespace');
	$this -> __verifyValid(@validConfigs);
	return;
}

#==========================================
# test_volNameUnique
#------------------------------------------
sub test_volNameUnique {
	# ...
	# Test that a non unique volume name generates an error
	# ---
	my $this = shift;
	my $kiwi = $this -> {kiwi};
	my $configFile = $this -> {dataDir} . '/volNameNonUnique.xml';
	my $validator = $this -> __getValidator($configFile);
	my $res = $validator -> validate();
	my $msg = $kiwi -> getMessage();
	my $expected = "Found non unique volume name 'base'.";
	$this -> assert_str_equals($expected, $msg);
	my $msgT = $kiwi -> getMessageType();
	$this -> assert_str_equals('error', $msgT);
	my $state = $kiwi -> getState();
	$this -> assert_str_equals('failed', $state);
	# Test this condition last to get potential error messages
	$this -> assert_null($res);
	return;
}

#==========================================
# Private helper methods
#------------------------------------------
#==========================================
# __getInvalidFiles
#------------------------------------------
sub __getInvalidFiles {
	# ...
	# Helper to get a list of invalid files with $(prefix)Invalid_*.xml
	# naming convention.
	# ---
	my $this   = shift;
	my $prefix = shift;
	return glob $this -> {dataDir} . $prefix . 'Invalid_*.xml';
}

#==========================================
# __getValidator
#------------------------------------------
sub __getValidator {
	# ...
	# Helper function to create a KIWIXMLValidator object
	# ---
	my $this         = shift;
	my $confFileName = shift;
	my $validator = KIWIXMLValidator -> new(
		$confFileName,
		$this -> {dataDir} . 'revision.txt',
		$this -> {schema},
		$this -> {xslt}
	);
	return $validator;
}

#==========================================
# __getValidFiles
#------------------------------------------
sub __getValidFiles {
	# ...
	# Helper to get a list of invalid files with $(prefix)Valid_*.xml
	# naming convention.
	# ---
	my $this   = shift;
	my $prefix = shift;
	return glob $this -> {dataDir} . $prefix . 'Valid_*.xml';
}

#==========================================
# __verifyValid
#------------------------------------------
sub __verifyValid {
	# ...
	# Helper to verify a list of valid config files.
	# This is common to all test cases as each XML validation is validated
	# with faling and vaild conditions. For valid configuration files
	# the state of the logging mechanism is always the same, thus this is
	# common to all test cases.
	# ---
	my ($this, @validConfigs) = @_;
	my $kiwi = $this -> {kiwi};
	for my $vConfFile (@validConfigs) {
		my $validator = $this -> __getValidator($vConfFile);
		$validator -> validate();
		my $msg = $kiwi -> getMessage();
		$this -> assert_str_equals('No messages set', $msg);
		my $msgT = $kiwi -> getMessageType();
		$this -> assert_str_equals('none', $msgT);
		my $state = $kiwi -> getState();
		$this -> assert_str_equals('No state set', $state);
		# Test this condition last to get potential error messages
		$this -> assert_not_null($validator);
	}
	return;
}

1;
