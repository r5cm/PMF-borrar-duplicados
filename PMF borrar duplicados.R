# Este script borra los registros duplicados de los objetos de
# reportes del Plan de Manejo de Finca (Diagnóstico y Seguimiento). Además
# actualiza los objetos de Taro para que se disparen los process y
# workflow rules que crean los registros de los objetos de reportes.

# LOGIN A SALESFORCE ------------------------------------------------------


library(RForcecom)
username <- readline(prompt = "Enter username: ")
password <- readline(prompt = "Enter password: ")
instanceURL <- "https://taroworks-8629.cloudforce.com/"
apiVersion <- "36.0"
session <- rforcecom.login(username, password, instanceURL, apiVersion)


# BORRAR REPETIDOS FMP DIAGNOSTIC -----------------------------------------

query <- "SELECT Id FROM FMP_Diagnostics_Targets_Definition_MYE__c WHERE Last_parent_record_update__c = 0"

borrar.diag <- rforcecom.query(session, query)

job_info <- rforcecom.createBulkJob(session, 
                                    operation='delete', 
                                    object='FMP_Diagnostics_Targets_Definition_MYE__c')

batches_info <- rforcecom.createBulkBatch(session, 
                                          jobId=job_info$id, 
                                          borrar.diag, 
                                          multiBatch = TRUE, 
                                          batchSize = 50)

# Estado de los batches
batches_status <- lapply(batches_info,
                         FUN=function(x){
                               rforcecom.checkBatchStatus(session, 
                                                          jobId=x$jobId, 
                                                          batchId=x$id)
                         })
status <- c()
records.processed <- c()
records.failed <- c()
for(i in 1:length(batches_status)) {
      status[i] <- batches_status[[i]]$state
      records.processed[i] <- batches_status[[i]]$numberRecordsProcessed
      records.failed[i] <- batches_status[[i]]$numberRecordsFailed
}
data.frame(status, records.processed, records.failed)

# Detalles de cada batch
batches_detail <- lapply(batches_info, 
                         FUN=function(x){
                               rforcecom.getBatchDetails(session, 
                                                         jobId=x$jobId, 
                                                         batchId=x$id)
                         })

# Cerrar trabajo
close_job_info <- rforcecom.closeBulkJob(session, jobId=job_info$id)


# BORRAR REPETIDOS FMP FOLLOW UP ------------------------------------------

query <- "SELECT Id FROM FMP_Follow_Up_M_E__c WHERE Last_parent_record_update__c = 0"

borrar.fu <- rforcecom.query(session, query)

job_info <- rforcecom.createBulkJob(session, 
                                    operation='delete', 
                                    object='FMP_Diagnostics_Targets_Definition_MYE__c')

batches_info <- rforcecom.createBulkBatch(session, 
                                          jobId=job_info$id, 
                                          borrar.fu, 
                                          multiBatch = TRUE, 
                                          batchSize = 500)

# Estado de los batches
batches_status <- lapply(batches_info, 
                         FUN=function(x){
                               rforcecom.checkBatchStatus(session, 
                                                          jobId=x$jobId, 
                                                          batchId=x$id)
                         })
status <- c()
records.processed <- c()
records.failed <- c()
for(i in 1:length(batches_status)) {
      status[i] <- batches_status[[i]]$state
      records.processed[i] <- batches_status[[i]]$numberRecordsProcessed
      records.failed[i] <- batches_status[[i]]$numberRecordsFailed
}
data.frame(status, records.processed, records.failed)


# Detalles de cada batch
batches_detail <- lapply(batches_info, 
                         FUN=function(x){
                               rforcecom.getBatchDetails(session, 
                                                         jobId=x$jobId, 
                                                         batchId=x$id)
                         })

# Cerrar trabajo
close_job_info <- rforcecom.closeBulkJob(session, jobId=job_info$id)


# DISPARAR PROCESS FMP DIAGNOSTIC -----------------------------------------
upd.diag <- rforcecom.retrieve(session, "FMP_Diagnostic_TargetDefinition__c",
                               c("Id", "BaseLineAnswer1__c"))

job_info <- rforcecom.createBulkJob(session, 
                                    operation='update', 
                                    object='FMP_Diagnostic_TargetDefinition__c')

batches_info <- rforcecom.createBulkBatch(session, 
                                          jobId=job_info$id, 
                                          upd.diag, 
                                          multiBatch = TRUE, 
                                          batchSize = 30)

# Estado de los batches
batches_status <- lapply(batches_info, 
                         FUN=function(x){
                               rforcecom.checkBatchStatus(session, 
                                                          jobId=x$jobId, 
                                                          batchId=x$id)
                         })
status <- c()
records.processed <- c()
records.failed <- c()
for(i in 1:length(batches_status)) {
      status[i] <- batches_status[[i]]$state
      records.processed[i] <- batches_status[[i]]$numberRecordsProcessed
      records.failed[i] <- batches_status[[i]]$numberRecordsFailed
}
data.frame(status, records.processed, records.failed)

# Detalles de cada batch
batches_detail <- lapply(batches_info, 
                         FUN=function(x){
                               rforcecom.getBatchDetails(session, 
                                                         jobId=x$jobId, 
                                                         batchId=x$id)
                         })

# Cerrar trabajo
close_job_info <- rforcecom.closeBulkJob(session, jobId=job_info$id)


# DISPARAR PROCESS FMP FOLLOW UP ------------------------------------------


