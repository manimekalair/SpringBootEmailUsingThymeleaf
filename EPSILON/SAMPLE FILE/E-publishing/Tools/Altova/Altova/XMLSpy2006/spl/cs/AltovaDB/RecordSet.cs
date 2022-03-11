//
// RecordSet.cs
//
// This file was generated by [=$Host].
//
// YOU SHOULD NOT MODIFY THIS FILE, BECAUSE IT WILL BE
// OVERWRITTEN WHEN YOU RE-RUN CODE GENERATION.
//
// Refer to the [=$HostShort] Documentation for further details.
// [=$HostURL]
//

using System;
using System.Collections;
using System.Data;
using Altova.Types;

namespace Altova.Db
{

	public abstract class RecordSet 
	{
		#region Members
		protected Database		database 			= null;
		protected bool			isReadAccess 		= true;

		protected ArrayList		commands 			= new ArrayList();

		protected IDbConnection	actConnection		= null;
		// Note: use the same connection for all batch-commands using IDataReader to ensure that variables are valid for the same session
		// Note: always .Close() connection after the last use of the object
		protected IDataReader	actResultSet		= null;
		// Note: Only one IDataReader is allowed to be open on the same connection
		// Note: Always close old IDateReaders to ensure not blocking the connection and due to ressource-needs.

		protected SchemaInt		mapforceDelRows		= new SchemaInt( 0 );
		#endregion Members

		#region Construction and destruction
		public RecordSet(Database database, bool isReadAccess) 
		{
			this.database = database;
			this.isReadAccess = isReadAccess;
		}
		#endregion Construction and destruction

		#region Accessors
		public Database Database
		{
			get
			{
				return database;
			}
		}

		public ArrayList Commands
		{
			get
			{
				return commands;
			}

			set
			{
				commands = value;
			}
		}

		public bool HasResultSet
		{
			get
			{
				return actResultSet != null;
			}
		}

		public SchemaInt	NumberOfRowsToDelete
		{
			get
			{
				return mapforceDelRows;
			}
		}
		#endregion Accessors

		#region Operations
		public abstract bool Read( bool bClearIfEmpty );

		public abstract void Prepare( bool bReadOnlyAccess );

		public abstract ISchemaType GetValueByName( string column );

		public long	Execute( ArrayList commands )
		{	
			if( commands != null  &&  commands.Count > 0 )
				this.commands = commands;
			long nRecordsAffected = 0;

			try
			{
				if( isReadAccess )
				{
					actConnection = database.CreateConnection();
					actConnection.Open();
					ClearResultSet();
				}
				else
					actConnection = database.ConnectionForModify;
			}
			catch( Exception e )
			{
				throw new DBConnectionException( DBConnectionException.EErrorKind.Open, database.ConnectionString, e.Message );
			}

			foreach( Command command in this.commands )
			{
				// Prepare command
				IDbCommand dbCommand;
				try
				{
					dbCommand = actConnection.CreateCommand();
					dbCommand.CommandText = command.Statement;
					if( !isReadAccess )
						dbCommand.Transaction = database.Transaction;
				}
				catch( Exception e )
				{
					throw new DBExecuteException( DBExecuteException.EErrorKind.PrepareCommand, command.Statement, e.Message );
				}

				// Add parameters
				try
				{
					foreach( FieldValue parameter in command.Parameters )
					{
						if( parameter.IsAutoUpdate )
						{
							ISchemaType val = GetValueByName( parameter.Value.ToString() );
							val.AddCommandParameter( dbCommand );
						}
						else
							parameter.Value.AddCommandParameter( dbCommand );
					}
					dbCommand.Prepare();
				}
				catch( Exception e )
				{
					throw new DBExecuteException( DBExecuteException.EErrorKind.PrepareParams, command.Statement, e.Message );
				}

				// execute command and assign resultset
				int nActRecordsAffected = 0;
				try
				{
					actResultSet = dbCommand.ExecuteReader();
					if( !isReadAccess )
					{
						nActRecordsAffected = ( Read( false ) ? -1 : 0);
						if( actResultSet.RecordsAffected >0 && nActRecordsAffected <= 0 )
							nActRecordsAffected = actResultSet.RecordsAffected;
					}
				}
				catch( Exception e )
				{
					bool	bErrorHandled = false;
					string 	sDescription = e.Message;

					// IBM/DB2: with this database-kind when UPDATE, DELETE or FETCH doesnot affect rows an error is thrown by the ODBC-driver
					// In reality the statement succeeds --> act as if it is so and ignore this specific error
					if( sDescription.IndexOf( "\[IBM\]" ) == 0  &&
						sDescription.IndexOf( "\[DB2" ) >= 0  &&  
						sDescription.IndexOf( "SQL0100W" ) >= 0
					)
						bErrorHandled = true;

					// Node: Add additional internal error-handling mechanism here

					if( !bErrorHandled )
					{
						string sMsg = "Runtime database error: " + sDescription;
						throw new DBExecuteException( DBExecuteException.EErrorKind.Execute, command.Statement, e.Message );
					}
				}

				// handle affected rows
				if( !isReadAccess )
				{
					if( nActRecordsAffected == -1  ||  nRecordsAffected == -1 )
						nRecordsAffected = -1;
					else
						nRecordsAffected += nActRecordsAffected;

					try
					{
						if( command.IsAutoReadFieldsIntoBuffer )
							while( NextResult() )
								Read( false );

						ClearResultSet();
					}
					catch( Exception e )
					{
						throw new DBExecuteException( DBExecuteException.EErrorKind.Execute, command.Statement, e.Message );
					}
					
					dbCommand.Dispose();	// Have to explicitly call Dispose(), otherwise the cursor may remain open.
					// Important: You MUST close all dataReaders which depend on this command before, 
					// otherwise you'll get confusing errors when trying to commit transactions.
				}
			}

			return nRecordsAffected;
		}

		public bool HasColumn( string column )
		{
			try
			{
				int nColumn = actResultSet.GetOrdinal( column );
			}
			catch( IndexOutOfRangeException )
			{
				return false;
			}
			return true;
		}

		public bool Read()
		{
			return Read( true );
		}

		public bool NextResult()
		{
			if( !HasResultSet )
				return false;
			try
			{
				if(	actResultSet.NextResult() )
					return true;
				ClearResultSet();
			}
			catch( Exception e )
			{
				throw new DBExecuteException( DBExecuteException.EErrorKind.ReadNextResult, "NextResult", e.Message );
			}
			return false;
		}

		public void Close()
		{
			ClearResultSet();
		}

		#endregion Operation

		#region Internal Methods
		protected void ClearResultSet()
		{
			if( actResultSet != null )
			{
				if( !actResultSet.IsClosed )
					actResultSet.Close();
				actResultSet = null;
				if( isReadAccess )
				{
					if( actConnection.State == ConnectionState.Open )
						actConnection.Close();
					actConnection = null;
				}
			}
		}
		#endregion Internal Methods
	}
}